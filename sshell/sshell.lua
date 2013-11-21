local currentPath = "";
function setPath(path)
    currentPath = path;
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
    
    --In the future these paths could be loaded from disk, opening the possibility for user configuration of environment paths
    local searchPaths = {
        fs.combine(currentPath, words[1]),  --Assume name is relative path to a program
        fs.combine("hdd", words[1]),        --Assume name is a program in the root system directory
    };
    
    --Search user configured paths
    --Either a absolute path, which the name will be appended to
    --Or a relative path, which starts with a * and the name will be appended to and is relative to current working directory
    if compunet_fs.exists("user") and compunet_fs.exists("user/sshell_search_paths") then
        local file = compunet_fs.open("user/sshell_search_path", "r");
        if file then
            repeat
                local line = manifestHandle.readLine();
                if line then
                    if line[0] == "+" then
                        line = fs.combine(currentPath, line.sub(2));
                    end
                
                    table.insert(searchPaths, fs.combine(line, words[1]));
                end
            until not line
        
            file.close();
        end
    end
    
    local matches = {};
    for _, p in ipairs(searchPaths) do
        if compunet_fs.exists(p) then
            table.insert(matches, p);
        end
    end
    
    if #matches == 0 then
        print("Program \"" .. tostring(words[1]) .. "\" not found");
    else
        local program = matches[1];
        
        --Open file and Read entire file as string
        local handle = compunet_fs.open(program, "r");
        local programSource = handle.readAll();
        handle.close();
        
        local func, err = loadstring(programSource);
        if not func then
            print("Program loading error: " .. err);
        else
            func();
        end
    end
end

function Run()
    print("Super Shell v1");
    while true do
        term.write("> ");
        local input = read();
        ProcessInput(input);
    end
end

local args = {...}
if args[1] == "run" then
    Run();
end