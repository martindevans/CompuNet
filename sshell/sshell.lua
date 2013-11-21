local exited = false;
function exit()
    exited = true;
end

local currentWorkingDirectory = "hdd";
function dir()
    return currentWorkingDirectory;
end

function setDir(path)
    currentWorkingDirectory = path;
end

local searchPath = "./:hdd:hdd/rom/programs";
function setPath(path)
    searchPath = path;
end

function path()
    return searchPath;
end

function resolve(localpath)
    fs.combine(currentWorkingDirectory, localpath);
end

function searchPaths()
    --Relative to cwd
    local searchPaths = { dir() };
    
    --search all configured directories in PATH
    for part in searchPath:sub(2):gmatch("[^:]+") do
        table.insert(searchPaths, part);
    end
    
    return searchPaths;
end

function resolveProgram(name)
    name = aliases()[name] or name;

    --Find how many of these paths actually exist
    local matches = {};
    for _, p in ipairs(searchPaths(name)) do
        local f = fs.combine(p, name);
        if compunet_fs.exists(f) then
            table.insert(matches, f);
        end
    end
    
    if #matches == 0 then
        return nil;
    else
        return matches[1];
    end
end

local aliasMappings = {};
function aliases()
    return aliasMappings;
end

function setAlias(alias, program)
    aliasMappings[alias] = program;
end

function clearAlias(alias)
    aliasMappings[alias] = nil;
end

function programs(hidden)
    local results = {};
    for _, path in searchPaths() do
        if compunet_fs.exists(path) then
            for _, fse in compunet_fs.list(path) do
                if not compunet_fs.isDir(fse) and hidden or fse.sub(1,1) ~= "." then
                    table.insert(results, fse);
                end
            end
        end
    end
end

function run(program, arguments)
    --Args are either an array of args (take that straight) or a string (split that up)
    local words = {};
    if (type(arguments) == "table") then
        words = arguments;
    elseif (type(arguments == "string")) then
        words = SplitSections(arguments);
    else
        print("Arguments must be a string!");
    end
    
    --Open file and Read entire file as string
    local handle = compunet_fs.open(program, "r");
    local programSource = handle.readAll();
    handle.close();
    
    local func, err = loadstring(programSource);
    if not func then
        print("Program loading error: " .. err);
    else
        func(unpack(words));
    end
end

function getRunningProgram()
    error("Not Implemented");
end

--Capture "sections", a section is space separated, or delimited by quotes (" or ')
local function SplitSections(str)
    local words = {};
    local word = "";
    local quote = "";
    for c in string.gmatch(str, ".") do
        if c == quote then
            quote = "";
            table.insert(words, word);
            word = "";
        elseif c == " " then
            if quote == "" then
                if word ~= "" then
                    table.insert(words, word);
                end
                word = "";
            else
                word = word .. c;
            end
        elseif c == "\"" or c == "\'" then
            quote = c;
        else
            word = word .. c;
        end
    end
    
    if word ~= "" then
        table.insert(words, word);
    end
    
    return words;
end

local function ProcessInput(input)
    local words = SplitSections(input);
    
    --Find a program at path words[1]
    --Execute program with args words[2] -> words[#words]
    
    local program = resolveProgram(words[1]);
    
    if not program then
        print("Program \"" .. tostring(words[1]) .. "\" not found");
    else
        table.remove(words, 1);
        run(program, words);
    end
end

function Run()
    print("Super Shell v1");
    while not exited do
        term.write(dir() .. "> ");
        local input = read();
        ProcessInput(input);
    end
    exited = false;
end

local args = {...}
if args[1] == "run" then
    Run();
end