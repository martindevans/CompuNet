local path = "";
function SetDirectory(directoryPath)
    path = directoryPath;
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
    
    print(words[1]);
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