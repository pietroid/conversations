import 'package:twilio_conversations/twilio_conversations.dart';

class User {
  final String _identity;
  Attributes _attributes;
  String? _friendlyName;
  bool _isNotifiable = false;
  bool _isOnline = false;
  bool _isSubscribed = false;

  //#region Public API properties
  /// Method that returns the friendlyName from the user info.
  String? get friendlyName {
    return _friendlyName;
  }

  /// Returns the identity of the user.
  String get identity {
    return _identity;
  }

  /// Return user's online status, if available,
  bool get isOnline {
    return _isOnline;
  }

  /// Return user's push reachability.
  bool get isNotifiable {
    return _isNotifiable;
  }

  /// Check if this user receives real-time status updates.
  bool get isSubscribed {
    return _isSubscribed;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }
  //#endregion

  User(
    this._identity,
    this._attributes,
    // this.friendlyName,
    // this.isNotifiable,
    // this.isOnline,
    // this.isSubscribed,
  );

  /// Construct from a map.
  factory User.fromMap(Map<String, dynamic> map) {
    final user = User(
      map['identity'],
      map['attributes'] != null
          ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
          : Attributes(AttributesType.NULL, null),
    );
    user._updateFromMap(map);
    return user;
  }

  //TODO: review _updateFromMap usage, and ensure used as needed
  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _friendlyName = map['friendlyName'];
    _isOnline = map['isOnline'] ?? false;
    _isNotifiable = map['isNotifiable'] ?? false;
    _isSubscribed = map['isSubscribed'] ?? false;
    _attributes = map['attributes'] != null
        ? Attributes.fromMap(map['attributes'].cast<String, dynamic>())
        : _attributes;
  }

  //TODO: implement setFriendlyName
  //TODO: implement setAttributes
}
