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
    
    local searchPaths = {
        fs.combine(currentPath, words[1]),  --Assume name is relative path to a program
        words[1],                           --Assume name is a program in the root directory
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
    
    for _, p in ipairs(searchPaths) do
        print(p);
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