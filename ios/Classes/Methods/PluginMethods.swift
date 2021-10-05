import Flutter
import TwilioConversationsClient

class PluginMethods: NSObject, TWCONPluginApi {
    let TAG = "PluginMethods"

    func debugEnableNative(_ enableNative: NSNumber, enableSdk: NSNumber, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        SwiftTwilioConversationsPlugin.nativeDebug = enableNative.boolValue
        if enableSdk.boolValue {
            TwilioConversationsClient.setLogLevel(TCHLogLevel.debug)
        } else {
            TwilioConversationsClient.setLogLevel(TCHLogLevel.warning)
        }
    }
    
    func createJwtToken(_ jwtToken: String?, completion: @escaping (TWCONConversationClientData?, FlutterError?) -> Void) {
        guard let jwtToken = jwtToken else {
            return completion(nil, FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }
        debug("create => jwtToken: \(jwtToken)")
        
        let properties = TwilioConversationsClientProperties()
        //TODO add region to properties
                
        TwilioConversationsClient.conversationsClient(
            withToken: jwtToken,
            properties: properties,
            delegate: SwiftTwilioConversationsPlugin.clientListener,
            completion: { (result: TCHResult, conversationsClient: TwilioConversationsClient?) in
                if result.isSuccessful {
                    SwiftTwilioConversationsPlugin.debug("SwiftTwilioConversationsPlugin.create => ConversationsClient.create onSuccess: myIdentity is '\(conversationsClient?.user?.identity ?? "unknown")'")
                    conversationsClient?.delegate = SwiftTwilioConversationsPlugin.clientListener
                    SwiftTwilioConversationsPlugin.instance?.client = conversationsClient
                    let clientData = Mapper.conversationsClientToPigeon(conversationsClient)
                    completion(clientData, nil)
                } else {
                    SwiftTwilioConversationsPlugin.debug("SwiftTwilioConversationsPlugin.create => ConversationsClient.create onError: \(String(describing: result.error))")
                    completion(nil, FlutterError(code: "ERROR", message: "Error creating client, Error: \(result.error.debugDescription)", details: nil))
                }
        })
    }
    
    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
