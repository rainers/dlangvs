module genvcxfilters;
import std.array;
import std.file;
import std.path;
import std.stdio;
import std.string;
import std.uuid;
import std.uni;
import std.xml;

void main(string[] args)
{
	if (args.length > 1 && args[1] == "-?")
		throw new Exception("usage: " ~ args[0] ~ " <root> <path>...");

	string root = args.length > 1 ? args[1] : "--";
	//string filterfile = args.length > 1 ? args[1] : "--";

	Document doc;
	version(none) //if (std.file.exists(filterfile))
	{
		string s = cast(string) std.file.read(filterfile);

		// Check for well-formedness
		check(s);

		// Make a DOM tree
		doc = new Document(s);
	}
	else
	{
		auto tag = new Tag("Project");
		tag.attr["ToolsVersion"] = "4.0";
		tag.attr["xmlns"] = "http://schemas.microsoft.com/developer/msbuild/2003";
		doc = new Document(tag);
	}

    bool[string] filters;
    Element[] filterItems;
    Element[] srcItems;

    string cwd = getcwd();
    string[] paths = args.length > 2 ? args[2..$] : (&cwd)[0..1];

    // Iterate the current directory in breadth
    foreach (srcpath; paths)
    foreach (string name; dirEntries(srcpath, SpanMode.breadth))
    {
        string ext = extension(name).toLower;
        if (ext == ".d" || ext == ".c" || ext == ".h")
        {
            void addFilter(string fname)
            {
                if (fname.length && fname != "." && fname !in filters)
                {
                    addFilter(dirName(fname));

                    filters[fname] = true;
                    auto elem = new Element("ItemGroup");
                    auto item = new Element("Filter");
                    item.tag.attr["Include"] = fname;
                    auto uid = new Element("UniqueIdentifier");
                    uid.items ~= new Text("{" ~ randomUUID.toString() ~ "}");
                    item.items ~= uid;
                    elem.items ~= item;
                    filterItems ~= elem;
                }
            }
            auto relname = relativePath(name, srcpath);
            auto filtername = dirName(relname);
            while (filtername.startsWith("../") || filtername.startsWith("..\\"))
                filtername = filtername[3..$];
            if (filtername.startsWith(root))
                filtername = filtername[root.length..$];
            while (filtername.startsWith("/") || filtername.startsWith("\\"))
                filtername = filtername[1..$];
                
            addFilter(filtername);
            auto elem = new Element("ItemGroup");
            auto item = new Element(ext == ".c" ? "ClCompile" : ext == ".h" ? "ClInclude" : "DCompile");
            item.tag.attr["Include"] = relname;
            auto filter = new Element("Filter");
            filter.items ~= new Text(filtername);
            item.items ~= filter;
            elem.items ~= item;
            srcItems ~= elem;
        }
    }

    doc.items ~= filterItems;
    doc.items ~= srcItems;
	writeln(join(doc.pretty(3),"\n"));
}
