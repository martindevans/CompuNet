local _fs = fs;

local function CreateFileSystemMount(root)
    return {
        Root = root,
        
        isAlive = function(mount)
            return _fs.exists(mount.Root);
        end,
        
        list = function(mount, path)
            return _fs.list(_fs.combine(mount.Root, path));
        end,
        
        exists = function(mount, path)
            return _fs.exists(_fs.combine(mount.Root, path));
        end,
        
        isDir = function(mount, path)
            return _fs.isDir(_fs.combine(mount.Root, path));
        end,
        
        isReadOnly = function(mount, path)
            return _fs.isReadOnly(_fs.combine(mount.Root, path));
        end,
        
        getSize = function(mount, path)
            return _fs.getSize(_fs.combine(mount.Root, path));
        end,
        
        getFreeSpace = function(mount, path)
            return _fs.getFreeSpace(_fs.combine(mount.Root, path));
        end,
        
        makeDir = function(mount, path)
            return _fs.makeDir(_fs.combine(mount.Root, path));
        end,
        
        delete = function(mount, path)
            return _fs.delete(_fs.combine(mount.Root, path));
        end,
        
        open = function(mount, path, mode)
            return _fs.open(_fs.combine(mount.Root, path), mode);
        end,
    }
end

local function CreateDriveMount(drive)
    local _fsMount = CreateFileSystemMount(drive.getMountPath());
    
    local update_fsMount = function()
        _fsMount.Root = drive.getMountPath();
    end
    
    return {
        isAlive = function(mount)
            return drive.isDiskPresent() and drive.hasData();
        end,
        
        list = function(mount, path)
            update_fsMount();
            return _fsMount:list(path);
        end,
        
        exists = function(mount, path)
            update_fsMount();
            return _fsMount:exists(path);
        end,
        
        isDir = function(mount, path)
            update_fsMount();
            return _fsMount:isDir(path);
        end,
        
        isReadOnly = function(mount, path)
            update_fsMount();
            return _fsMount:isReadOnly(path);
        end,
        
        getSize = function(mount, path)
            update_fsMount();
            return _fsMount:getSize(path);
        end,
        
        getFreeSpace = function(mount, path)
            update_fsMount();
            return _fsMount:getFreeSpace(path);
        end,
        
        makeDir = function(mount, path)
            update_fsMount();
            return _fsMount:makeDir(path);
        end,
        
        delete = function(mount, path)
            update_fsMount();
            return _fsMount:delete(path);
        end,
        
        open = function(mount, path, mode)
            update_fsMount();
            return _fsMount.open(path, mode);
        end,
    }
end

local function CreateDriveDriver()
    local drives = {};
    return {
        Drive = function(peripherals)
            for _,p in ipairs(peripherals) do
                local device = peripheral.wrap(p);
                Mount(p, CreateDriveMount(device));
            end
        end,
        
        Devices = function()
            return drives;
        end
    };
end

local mounts = {};
function Mount(name, mount)
    mounts[name] = mount;
end

local function SplitPath(path)
    local parts = {};
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part);
    end
    return parts;
end

local function GetPathAndMountAndError(path)
    local parts = SplitPath(path);
    
    if #parts == 0 then
        return parts, nil, "root";
    end
    
    local mountName = parts[1];
    table.remove(parts, 1);
    
    local mount = mounts[mountName];
    if not mount then
        return parts, nil, "not found";
    end
    
    if not mount:isAlive() then
        return parts, nil, "not alive";
    end
    
    return parts, mount, "ok";
end

function list(path)
    local parts, mount, status = GetPathAndMountAndError(path);
    
    if not mount then
        if status == "root" then
            local m = {};
            for n,_ in pairs(mounts) do
                table.insert(m, n);
            end;
            return m;
        else
            return nil, status;
        end
    end
    
    return mount:list(table.concat(parts, "/"));
end

function exists(path)
    local parts, mount, status = GetPathAndMountAndError(path);
    
    if not mount then
        if status == "root" then
            return mounts[parts[1]] ~= nil;
        else
            return false;
        end
    end
    
    return mount:exists(table.concat(parts, "/"));
end

function isDir(path)
    local parts, mount, status = GetPathAndMountAndError(path);
    
    if not mount then
        if status == "root" then
            return true;
        else
            return false;
        end
    end
    
    return mount:isDir(table.concat(parts, "/"));
end

function isReadOnly(path)
    error("Not Implemented");
end

function getName(path)
    return _fs.getName(path);
end

function getDrive(path)
    error("Not Implemented");
end

function getSize(path)
    error("Not Implemented");
end

function getFreeSpace(path)
    error("Not Implemented");
end

function makeDir(path)
    error("Not Implemented");
end

function move(pathFrom, pathTo)
    error("Not Implemented");
end

function copy(pathFrom, pathTo)
    error("Not Implemented");
end

function delete(path)
    error("Not Implemented");
end

function combine(basePath, localPath)
    return _fs.combine(basePath, localPath);
end

function open(path, mode)
    local parts, mount, status = GetPathAndMountAndError(path);
    
    if not mount then
        if status == "root" then
            local m = {};
            for n,_ in pairs(mounts) do
                table.insert(m, n);
            end;
            return m;
        else
            return nil, status;
        end
    end
    
    return mount:open(table.concat(parts, "/"), mode);
end

--Create driver for any attached floppy drives
local driveDriver = CreateDriveDriver();
compunet_core.RegisterDriver("drive", driveDriver);

--Mount the local machine as sys
Mount("hdd", CreateFileSystemMount("/"));

function ReplaceFs()
    _G["fs"] = compunet_fs;
end