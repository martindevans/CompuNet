local function CreateFileSystemMount(root)
    return {
        Root = root,
        
        isAlive = function(mount)
            return fs.exists(mount.Root);
        end,
        
        list = function(mount, path)
            return fs.list(fs.combine(mount.Root, path));
        end,
        
        exists = function(mount, path)
            return fs.exists(fs.combine(mount.Root, path));
        end,
        
        isDir = function(mount, path)
            return fs.isDir(fs.combine(mount.Root, path));
        end,
        
        isReadOnly = function(mount, path)
            return fs.isReadOnly(fs.combine(mount.Root, path));
        end,
        
        getSize = function(mount, path)
            return fs.getSize(fs.combine(mount.Root, path));
        end,
        
        getFreeSpace = function(mount, path)
            return fs.getFreeSpace(fs.combine(mount.Root, path));
        end,
        
        makeDir = function(mount, path)
            return fs.makeDir(fs.combine(mount.Root, path));
        end,
        
        delete = function(mount, path)
            return fs.delete(fs.combine(mount.Root, path));
        end,
        
        open = function(mount, path, mode)
            return fs.open(fs.combine(mount.Root, path), mode);
        end,
    }
end

local function CreateDriveMount(drive)
    local fsMount = CreateFileSystemMount(drive.getMountPath());
    
    local updateFsMount = function()
        fsMount.Root = drive.getMountPath();
    end
    
    return {
        isAlive = function(mount)
            return drive.isDiskPresent() and drive.hasData();
        end,
        
        list = function(mount, path)
            updateFsMount();
            return fsMount:list(path);
        end,
        
        exists = function(mount, path)
            updateFsMount();
            return fsMount:exists(path);
        end,
        
        isDir = function(mount, path)
            updateFsMount();
            return fsMount:isDir(path);
        end,
        
        isReadOnly = function(mount, path)
            updateFsMount();
            return fsMount:isReadOnly(path);
        end,
        
        getSize = function(mount, path)
            updateFsMount();
            return fsMount:getSize(path);
        end,
        
        getFreeSpace = function(mount, path)
            updateFsMount();
            return fsMount:getFreeSpace(path);
        end,
        
        makeDir = function(mount, path)
            updateFsMount();
            return fsMount:makeDir(path);
        end,
        
        delete = function(mount, path)
            updateFsMount();
            return fsMount:delete(path);
        end,
        
        open = function(mount, path, mode)
            updateFsMount();
            return fsMount.open(path, mode);
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

function list(path)
    local parts = SplitPath(path);
    
    if #parts == 0 then
        local m = {};
        for n,_ in pairs(mounts) do
            table.insert(m, n);
        end;
        return m;
    end
    
    local mountName = parts[1];
    local mount = mounts[mountName];
    if not mount then
        return;
    end
    
    if not mount:isAlive() then
        return;
    end
    
    table.remove(parts, 1);
    return mount:list(table.concat(parts, "/"));
end

--Create driver for any attached floppy drives
local driveDriver = CreateDriveDriver();
compunet_core.RegisterDriver("drive", driveDriver);

--Mount the local machine as sys
Mount("hdd", CreateFilesystemMount("/"));