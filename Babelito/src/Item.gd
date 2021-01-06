extends Resource
class_name ItemResource

export var name : String
export var stackable : bool = false
export var max_stack_size : int = 1

enum ItemType { MeleeWeapon, RangedWeapon, Armor, Quest, Consumable}
enum ElementType {Neutral, Fire, Water, Earth, Electric, Time}
export (ItemType) var type
export (ElementType) var element
#
export var texture : Texture
export var mesh : Mesh
