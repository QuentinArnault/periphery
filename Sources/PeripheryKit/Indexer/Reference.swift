final class Reference: Entity {
    enum Kind: String {
        case `associatedtype` = "associatedtype"
        case `class` = "class"
        case `enum` = "enum"
        case enumelement = "enumelement"
        case `extension` = "extension"
        case extensionClass = "extension.class"
        case extensionEnum = "extension.enum"
        case extensionProtocol = "extension.protocol"
        case extensionStruct = "extension.struct"
        case functionAccessorAddress = "function.accessor.address"
        case functionAccessorDidset = "function.accessor.didset"
        case functionAccessorGetter = "function.accessor.getter"
        case functionAccessorMutableaddress = "function.accessor.mutableaddress"
        case functionAccessorSetter = "function.accessor.setter"
        case functionAccessorWillset = "function.accessor.willset"
        case functionConstructor = "function.constructor"
        case functionDestructor = "function.destructor"
        case functionFree = "function.free"
        case functionMethodClass = "function.method.class"
        case functionMethodInstance = "function.method.instance"
        case functionMethodStatic = "function.method.static"
        case functionOperator = "function.operator"
        case functionOperatorInfix = "function.operator.infix"
        case functionOperatorPostfix = "function.operator.postfix"
        case functionOperatorPrefix = "function.operator.prefix"
        case functionSubscript = "function.subscript"
        case genericTypeParam = "generic_type_param"
        case module = "module"
        case precedenceGroup = "precedencegroup"
        case `protocol` = "protocol"
        case `struct` = "struct"
        case `typealias` = "typealias"
        case varClass = "var.class"
        case varGlobal = "var.global"
        case varInstance = "var.instance"
        case varLocal = "var.local"
        case varParameter = "var.parameter"
        case varStatic = "var.static"

        var isFunctionKind: Bool {
            rawValue.hasPrefix("function")
        }

        var isVariableKind: Bool {
            rawValue.hasPrefix("var")
        }

        var declarationEquivalent: Declaration.Kind? {
            Declaration.Kind(rawValue: rawValue)
        }
    }

    let location: SourceLocation
    let kind: Kind
    let usr: String

    var parent: Entity?
    var declarations: Set<Declaration> = []
    var references: Set<Reference> = []
    var name: String?
    var isRelated: Bool = false

    init(kind: Kind, usr: String, location: SourceLocation) {
        self.kind = kind
        self.usr = usr
        self.location = location
    }

    var descendentReferences: Set<Reference> {
        Set(references.flatMap { $0.descendentReferences }).union(references)
    }

    var ancestralDeclaration: Declaration? {
        if let parent = parent as? Reference {
            return parent.ancestralDeclaration
        } else if let parent = parent as? Declaration {
            return parent
        }

        return nil
    }
}

extension Reference: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(usr)
        hasher.combine(location)
        hasher.combine(isRelated)
    }
}

extension Reference: Equatable {
    static func == (lhs: Reference, rhs: Reference) -> Bool {
        let usrIsEqual = lhs.usr == rhs.usr
        let locationIsEqual = lhs.location == rhs.location
        let kindIsEqual = lhs.kind == rhs.kind
        let relatedIsEqual = lhs.isRelated == rhs.isRelated

        return usrIsEqual && locationIsEqual && kindIsEqual && relatedIsEqual
    }
}

extension Reference: CustomStringConvertible {
    var description: String {
        let referenceType = isRelated ? "Related" : "Reference"

        return "\(referenceType)(\(descriptionParts.joined(separator: ", ")))"
    }

    var descriptionParts: [String] {
        let formattedName = name != nil ? "'\(name!)'" : "nil"

        return [kind.rawValue, formattedName, "'\(usr)'", location.shortDescription]
    }
}
