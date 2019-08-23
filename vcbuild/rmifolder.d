import std.file;
import std.path;
import std.stdio;

int main(string[] args)
{
    bool verbose = false;
    if (args.length == 1)
    {
        writeln("usage: ", baseName(args[0]), " [-v] <target> <dependencies>...");
        writeln("removes <target> if any of the dependencies is newer");
        return 1;
    }
    if (args[1] == "-v")
    {
        verbose = true;
        args = args[1..$];
    }
    string target = args[1];
    if (!std.file.exists(target))
    {
        if (verbose)
            writeln(target, " does not exist");
        return 0;
    }
    auto tm = timeLastModified(target);
    foreach(file; args[2..$])
    {
        auto dep = timeLastModified(file);
        if(timeLastModified(file) > tm)
        {
            if (verbose)
                writeln(file, " is newer than ", target, ", removing target");
            remove(target);
            break;
        }
        if (verbose)
            writeln(file, " (", dep, ") is not newer than ", target, " (", tm, ")");
    }
    return 0;
}