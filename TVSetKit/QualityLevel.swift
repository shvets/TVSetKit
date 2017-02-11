public enum QualityLevel {
  case low
  case medium
  case normal
  case high

  public static func availableLevels(_ count: Int) -> [QualityLevel] {
    var levels: [QualityLevel] = []

    switch count {
      case 1:
        levels = [.normal]

      case 2:
        levels = [.normal, .low]

      case 3:
        levels = [.high, .normal, .low]

      default:
        levels = [.high, .normal, .medium, .low]
    }

    return levels
  }

  public func nearestLevel(qualityLevels: [QualityLevel]) -> QualityLevel? {
    var nearestLevel: QualityLevel?

    if qualityLevels.count == 1 {
      nearestLevel = qualityLevels.first!
    }
    else if qualityLevels.contains(self) {
      nearestLevel = self
    }
    else {
      switch self {
      case .low:
        nearestLevel = qualityLevels.first!

      case .medium:
        nearestLevel = qualityLevels.contains(.normal) ? .normal : .high

      case .normal:
        nearestLevel = .high

      default:
        nearestLevel = qualityLevels.first!
      }
    }

    return nearestLevel
  }
}

extension QualityLevel: RawRepresentable {
  public typealias RawValue = String

  public init?(rawValue: RawValue) {
    switch rawValue {
    case "Low": self = .low
    case "Medium": self = .medium
    case "Normal": self = .normal
    case "High": self = .high

    default: return nil
    }
  }

  public var rawValue: RawValue {
    switch self {
    case .low: return "Low"
    case .medium: return "Medium"
    case .normal: return "Normal"
    case .high: return "High"
    }
  }
}
