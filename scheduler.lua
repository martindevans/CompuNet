--Cooperative thread scheduler
--Call coroutine.yield at any time in a process to yield control back to the scheduler

local currentProcess = nil;
local processes = {};

function Start(name, func, redirectOutput)
    local process = {
        name = name,
        co = coroutine.create(func),
        output = redirectOutput or terminalBuffer.CreateRedirectBuffer(51, 19),
        parent = currentProcess
    }
    processes[process] = true;
    
    os.queueEvent("process_started", name);
    
    return process;
end

function GetCurrentProcess()
    return currentProcess;
end

function GetProcess(name)
    return processes[name];
end

function GetProcessCount()
    local count = 0;
    for _,_ in pairs(processes) do
        count = count + 1;
    end
    return count;
end

function Run()
    local count = 1;
    while count > 0 do
        count = 0;
        
        local deadProcesses = {};

        for p,_ in pairs(processes) do
            if coroutine.status(p.co) == "dead" then
                table.insert(deadProcesses, p);
                print("Killing process " .. p.name);
            else
                count = count + 1;
            
                currentProcess = p;
                os.queueEvent("process_resumed", p.name);
                
                if p.output then
                    term.redirect(p.output);
                    p.output.makeActive(1, 1);
                end
                coroutine.resume(p.co);
                
                os.queueEvent("process_suspended", p.name);
                currentProcess = nil;
            end
        end
        
        for _,p in ipairs(deadProcesses) do
            os.queueEvent("process_ended", p.name);
            processes[p] = nil;
        end
        
        coroutine.yield();
    end
end