AddCSLuaFile()

RepProperty = {}
RepProperty.__index = RepProperty

-- TODO: Add Key/Value type
ReplicationType = 
{
    String = "String", -- A string property.
    Float = "Float", -- A float (decimal) value.
    Double = "Double", -- A double precision number.
    UInt = "UInt", -- An unsigned integer. Requires the amount of bits to be specified, or it will default to 32.
    Int = "Int", -- A signed integer. Requires the amount of bits to be specified, or it will default to 32.
    Bool = "Bool", -- A boolean, same as a bit value behind the scenes.
    Bit = "Bit", -- A single bit
    Color = "Color", -- A color (RGBA)
    Vector = "Vector", -- A Vector value (X Y Z)
    Normal = "Normal", -- A normalized vector (values must range from 0.0 to 1.0 in all components)
    Matrix = "VMatrix", -- A 4x4 matrix,
    Angle = "Angle", -- An angle.
    Entity = "Entity", -- An entity (internally, networks the EntIndex() using 16 bits)
    Table = "Table", -- Table properties must also be setup with Replicate, else it'll default to Read/WriteTable. You don't want that, do you?
    List = "List", -- A simple list, considered not ordered. Will be written as an ordinal list.
    OrderedList = "OrderedList", -- A simple list with ordered numerical keys (first key must be 1)
}

function RepProperty:new(inName, inType)
    local tbl =
    {
        name = inName,
        type = inType,
        bits = 32,
        value_type = nil,
        condition = nil,
        depends_on = nil,
        was_replicated = false,
    }

    setmetatable(tbl, RepProperty)
    return tbl
end

-- Key name of the property
AccessorFunc(RepProperty, "name", "Name")
-- ReplicationType of the property.
AccessorFunc(RepProperty, "type", "Type")
-- Amount of bits used for integers
AccessorFunc(RepProperty, "bits", "Bits")
-- The ReplicationType of the value for lists.
AccessorFunc(RepProperty, "value_type", "ValueType")
-- The condition in which this property will be written. A single bit will be written to determine whether or not the prop was replicated.
-- function(tbl), return true if the property should be written.
-- Only called when writing a table.
AccessorFunc(RepProperty, "condition", "ReplicationCondition")
-- If not nil, the RepProperty name this property depends on. It will only be written/read if the dependency's condition is true. 
-- Only works if the dependency has a replication condition.
AccessorFunc(RepProperty, "depends_on", "DependsOn")
-- Whether or not this property was replicated in the latest replication. Always true unless it depends on another/has a condition.
AccessorFunc(RepProperty, "was_replicated", "WasReplicated", FORCE_BOOL)


function RepProperty:AssertValid()
    local t = self:GetType()
    Replicate.Assert.NotNilOrEmptyString(self:GetName(), "Name")
    Replicate.Assert.IsValidReplicationType(t)

    if t == ReplicationType.Int or t == ReplicationType.UInt then
        Replicate.Assert.IsValidBitAmount(self:GetBits())
    end

    if t == ReplicationType.List or t == ReplicationType.OrderedList then
        Replicate.Assert.IsValidReplicationType(self:GetValueType())
        Replicate.Assert.IsValidBitAmount(self:GetBits())
    end

    local cond = self:GetReplicationCondition()
    if cond and not isfunction(cond) then
        error("Replication Condition must be a function.")
    end
end

setmetatable(RepProperty, {__call = RepProperty.new})