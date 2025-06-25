class_name Util


func find(array: Array, item: Node) -> int:
    for element in range(array.size()):
        if array[element] == item:
            return element
    return -1