// This is a VC server for Why3. It implements the following functionalities:
// * wait for connections on a unix domain socket (unix) or named pipe
//   (windows) for clients
// * clients can send requests for a process to spawn, including
//   timeout/memory limit
// * server will send back a filename containing the output of the process,
//   as well as the time taken and the exit code
//
// Command line options
// ====================
//
//    -j <n>      the maximum number of processes to spawn in parallel
//    --socket    the name of the socket or named pipe
//
//  Protocol
// =========
//
// A client request is a single line which looks like this:
//
//   id;timeout;memlimit;cmd;arg1;arg2;...;argn
//
// All items are separated by semicolons, and must not contain semicolons
// themselves (but may contain spaces). Their meaning is the following:
//   id       - a (ideally) unique identifier which identifies the request
//   timeout  - the allowed CPU time in seconds for this command;
//              this must be number, 0 for unlimited
//   memlimit - the allowed consumed memory for this command
//              this must be number, 0 for unlimited
//   cmd      - the name of the executable to run
//   arg(i)   - the commandline arguments of the command to run
//
// A server answer looks like this:
//
//   id;exitcode;time;timeout;file
//
// Their meaning is the following:
//   id       - the identifier of the request to which this answer belongs
//   exitcode - the exitcode of the executed program
//   time     - the time taken by the executed program
//   timeout  - 0 for regular exit or crash, 1 for program interrupt through
//              timeout
//   file     - the path to a file which contains the stdout and stderr of the
//              executed program
//
// There are two separate implementations on linux and windows, but both are
// very similar in structure and share some code (but should share much more).
// They are both essentially a single-threaded event loop, where the possible
// events are incoming clients, read/write operations on sockets, and
// terminating child processes. Lists of child processes and connected clients
// are maintained.

#ifdef _WIN32
# include "server-win.c"
#else
# include "server-unix.c"
#endif
