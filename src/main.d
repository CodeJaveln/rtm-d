import std.stdio;
import std.exception;

string usage = "Usage: rtm <cmd>

Commands:

  make             Make a new project directory.
  fn               Fetch paths by name.
  ft               Fetch paths by tags.
  version          Print version number and exit.
  help             Print usage and exit.
";

string projectName = "RTM";
string versionNumber = "0.0.0";

void printUsage(File f) {
    f.writeln(usage);
}

void printVersion() {
    //Added by AdrianKingen07 formatting the string epicly
    writefln("%s %s", projectName, versionNumber);
}

string getConfigPath() {
    import std.file : exists, mkdir;
    import std.path : expandTilde;

    auto configPath = "~/.config/rtm/".expandTilde;
    if (!configPath.exists) {
        configPath.mkdir;
    }

    return configPath;
}

string getDataPath() {
    return getConfigPath() ~ "projects.toml";
}

void formatToToml(File tomlFile, string name, string path, string[] tags) {
    enum fmt1 = "[[projects]]\nname=\"%s\"\npath=\"%s\"\ntags=[";
    enum fmt2 = "]\n\n";

    tomlFile.writef(fmt1, name, path);

    if (tags.length == 0) {
        tomlFile.writef(fmt2);
        return;
    }

    enum tagFmt = "\"%s\",";
    enum lastTagFmt = "\"%s\"";

    for (int i = 0; i < tags.length - 1; i++) {
        tomlFile.writef(tagFmt, tags[i]);
    }

    tomlFile.writef(lastTagFmt, tags[$ - 1]);

    tomlFile.writef(fmt2);
}

// Creates a new dir
// Adds absolute path to the toml and reference by name
// Optionally adds tags
void cmdMake(string[] cmdArgs) {
    import std.file;
    import std.getopt;

    string name;
    string[] tags;

    writeln(cmdArgs);

    arraySep = ",";
    auto optResult = getopt(cmdArgs,
        config.caseSensitive,
        config.required,
        "name|n", "Project name to display and search.", &name,
        "tags|t", "Project tags", &tags,
    );

    // Why is this never run???!?!
    // Fixed: It apparantly removed first arg as a "program name", me no likie
    if (optResult.helpWanted) {
        defaultGetoptPrinter(
            "Some funny intro text here",
            optResult.options
        );

        return;
    }

    auto cwd = getcwd();
    auto projectPath = cwd ~ "/" ~ name;
    projectPath.mkdir;

    writeln("new project");
    writeln("name: ", name);
    writeln("project tags: ", name);
    writeln("project path: ", projectPath);

    auto dataFile = File(getDataPath(), "a");
    formatToToml(dataFile, name, projectPath, tags);
}

int main(string[] args) {
    // parse cmd and "run" cmd
    enforce(args.length > 1, "error: Command required, provide 'help' to print usage.");

    auto cmd = args[1];

    // wanted to exclude cmd, but to make getopt happy first arg need to be irrelevant.
    auto cmdArgs = args[1 .. $];

    switch (cmd) {
        case "make":
            cmdMake(cmdArgs);
            break;
        case "fn":
            // Find name
            break;
        case "ft":
            // Fetch by tag
            break;
        case "help":
        case "-h":
        case "--help":
            stdout.printUsage;
            break;
        case "version":
        case "-v":
        case "--version":
            printVersion();
            break;
        default:
            stderr.printUsage;
            stderr.writefln("error: Unkown command '%s'.\n", args[1]);
            return 1;
    }

    return 0;
}
