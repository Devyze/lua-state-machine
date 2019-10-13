local Connections = {}
Connections.__index = Connections

function Connections.new()
    local self = setmetatable({}, Connections)

    self.__connections = {}

    return self
end

function Connections:Add(connection)
    print("connection added")
    table.insert(self.__connections, connection)
end

function Connections:Clean()
    for _, connection in pairs(self.__connections) do
        print("connection removed")
        connection:Disconnect()
    end
end

return Connections