import 'dart:async';
import 'dart:collection';
import 'dart:isolate';

/// Easy and convenient to use, thread-pool-like implementation for delegating
/// expensive tasks to a pool of isolates
///
/// Just pass the function and the desired params to [commission] and let
/// the site handle everything for you by returning a really parallel computed [Future] object.
/// If the [Site] currently holds a reference to an idle Isolate, then the requested computation
/// wil be delegated to it immediately. Otherwise a new [Isolate] is spawned, if it would
/// not exceed [SiteSetting.workersMax]. If this limit is exceeded has the task to wait
/// until any [Isolate] finishes its work on any other task.
///
/// Idle [Isolates] will die after [SiteSetting.workerTimeout].
class Site {

  /// Controls the whole behaviour of this Site and all its Isolates
  ///
  /// The site will not spawn more Isolates than defined by [SiteSetting.workersMax]
  /// and an idling [Isolate] will die after [SiteSetting.workerTimeout]
  final SiteSetting settings;

  /// Holds a reference to all workers currently alive
  final List<_Worker> _workers = [];

  /// Holds a reference to all jobs waiting for delegation to any
  /// [Isolate]
  final Queue<_Job> _jobs = new Queue();

  /// This controller is used to notify when a [_Job] was finished
  /// ignore: close_sinks
  StreamController streamController = new StreamController.broadcast();

  Site(this.settings);

  /// This will execute the [function] inside another Isolate and conveniently
  /// return a easy to handle [Future]
  ///
  /// Be careful: Isolates are not sharing any memory with each other,
  /// therefore try to pass immutable objects as arguments, because any
  /// transformation by [function] won't be reflected in the calling isolate.
  ///
  /// Spawns a new Isolate if all current Isolates are busy and
  /// [SiteSetting.workersMax] is not yet exceeded.
  ///
  /// Will wait for current working Isolates if [SiteSettings.workersMax] is indeed
  /// exceeded and all other Isolates are busy.
  Future<dynamic> commission(Function function,
      {List positionalArgs: const [], Map namedArgs: const{}}) async {
    BackgroundFunction backgroundFunction = new BackgroundFunction(function,
        positionalArguments: positionalArgs, namedArguments: namedArgs);

    _Job job = new _Job(this, backgroundFunction);
    _jobs.add(job);
    patrol();

    await for (dynamic finished in streamController.stream) {
      if (finished == job) {
        return job.result;
      }
    }
  }

  /// Encourages idle [Isolate]s to take a [_Job] from
  /// the Queue and will spawn new a new [Isolate] if necessary
  ///
  /// This method is automatically called.
  /// I cannot easily image a reason why this should
  /// be called manually!
  patrol() {
    _workers.forEach((worker) => worker.incite());
    if (_jobs.isNotEmpty) {
      if (_workers.length < settings.workersMax) {
        this._workers.add(
            new _Worker(this)
              ..start()
              ..incite());
        print("Site: Spawning worker. Total ${_workers.length}");
      }
    }
  }


  void _reportDeathOf(_Worker worker) {
    this._workers.remove(worker);
    print("Site: Worker $worker died. Left: ${_workers.length}");
  }


  /// Will shut down this [Site] and kill all
  /// open resources/[Isolate]s
  ///
  /// You should not use this Site ever again after
  /// calling this method.
  ///
  /// Also make sure to call this method after
  /// the [Site] is not needed anymore.
  void close() {
    this.streamController?.close();
    this.streamController = null;
    this._workers.forEach((worker) => worker.close());
    this._workers.clear();
  }

  finalize() {
    this.close();
  }
}

/// All preferences for a [Site]
class SiteSetting {

  /// How many worker [Isolates] can be spawned at max?
  final int workersMax;

  /// How long is an [Isolate] allowed to idle, before it is killed?
  final Duration workerTimeout;

  /// Will allow a maximum of 2 background [Isolate]s while
  /// killing idle [Isolate]s after 30 seconds
  static const SiteSetting STANDARD = const SiteSetting(2, const Duration(seconds: 30));

  /// Will allow a maximum of 16 background [Isolate]s while
  /// killing idle [Isolate]s after 5 minutes.
  ///
  /// This is only for heavy multitasking applications.
  /// Not quite sure if Dart is the right language here!
  static const SiteSetting HEAVY = const SiteSetting(16, const Duration(minutes: 5));

  /// Will allow a maximum of 2 background [Isolate] while
  /// killing idle [Isolate]s after 1 second.
  static const SiteSetting LIGHT = const SiteSetting(2, const Duration(seconds: 1));


  const SiteSetting(this.workersMax, this.workerTimeout);
}



/// Manages the connection to a dedicated [Isolate].
///
/// Manages its own [Isolate] and is able
/// to work on [_Job] objects.
class _Worker {

  /// The site this worker belongs to
  Site site;

  /// The workers own [Isolate]
  Isolate _isolate;

  /// Will be used for receiving messages
  /// from [_isolate]
  ReceivePort _receivePort;

  /// Will be used to send messages to
  /// [_isolate]
  ///
  /// This should be null-checked, since
  /// the port is received from the [_isolate]
  /// once it is running
  SendPort _sendPort;

  /// The current job, this Worker is working on,
  /// or null if the Worker is idle.
  _Job _currentJob;

  _Worker(this.site);

  /// Tells whether an [Isolate] is currently attached.
  /// Does NOT tell whether its IDLE or not!
  bool get running {
    return _isolate != null;
  }

  /// Will make this Worker start working on an available job
  /// if it is currently idle!
  void incite() {
    if (_currentJob == null && site._jobs.isNotEmpty) {
      _currentJob = site._jobs.removeFirst();
      print("Worker: start workiing on $_currentJob");
      _startWorking();
    }
  }


  /// Send the [_Job] object [_currentJob] to the Isolate,
  /// which will start working on it.
  void _startWorking() {
    assert(_currentJob != null);
    if(_sendPort!=null){
      print("Worker: delegating to isolate");
      _sendPort.send(_currentJob.function);
      print("Worker: waiting for isolate to finish");
    }
 }

 /// receives the result for the computation associated with
  /// [_currentJob] and will "finish" the associated future
  /// by assigning the result [x] to it.
  void _receive(dynamic x) {
    assert (_currentJob != null);
    _currentJob.result = x;
    _currentJob = null;
    incite();
  }

  /// Starting the Worker will
  /// spawn the [_isolate] and retrieve the [_sendPort].
  ///
  /// This will also lead in a call to [_startWorking] if
  /// a job is currently assigned.
  Future start() async {
    ReceivePort exitReceiver = new ReceivePort();
    exitReceiver.first.then((x) {
      this.close();
      site._reportDeathOf(this);
    });

    _receivePort = new ReceivePort();

    _WorkDay _workDay = new _WorkDay(site.settings, _receivePort.sendPort);
    _isolate =
    await Isolate.spawn(_entryPoint, _workDay, onExit: exitReceiver.sendPort);

    int counter = 0;
    _receivePort.listen((x) {
      if(counter == 0){
        _sendPort = x;
        if(_currentJob!=null) _startWorking();
      }
      else _receive(x);
      counter ++;
    });


  }


  /// Will kill the [Isolate] and this Worker should
  /// never be used again!
  void close() {
    _isolate?.kill();
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    _sendPort = null;
    _currentJob = null;
  }


  /// The entry point of [_isolate].
  static void _entryPoint(_WorkDay workDay) {
    ReceivePort receivePort = new ReceivePort();
    Stream receiveStream = receivePort.timeout(workDay.settings.workerTimeout,
        onTimeout: (EventSink sink) {
          print("Worker: timed out...");
          receivePort.close();
        });

    receiveStream.listen((BackgroundFunction backgroundFunction) {
      print("Worker: working");
      var result = backgroundFunction();
      workDay.sendPort.send(result);
      print("Worker: idle");
    });

    workDay.sendPort.send(receivePort.sendPort);
  }
}


/// The initial object sent to a [Isolate] by a [_Worker]
class _WorkDay {
  final SiteSetting settings;
  final SendPort sendPort;

  _WorkDay(this.settings, this.sendPort);
}



class _Job {
  final Site _site;
  final BackgroundFunction function;
  bool finished = false;
  dynamic _result;

  set result(dynamic result) {
    this._result = result;
    this.finished = true;
    this._site.streamController.add(this);
  }

  dynamic get result {
    return _result;
  }

  _Job(this._site, this.function);
}

class BackgroundFunction {
  final Function function;
  final List positionalArguments;
  final Map namedArguments;

  BackgroundFunction(this.function,
      {this.positionalArguments: const[],
        this.namedArguments: const{}});

  dynamic call() {
    return Function.apply(function, positionalArguments, namedArguments);
  }
}




