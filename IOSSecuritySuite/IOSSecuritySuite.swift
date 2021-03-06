//
//  IOSSecuritySuite.swift
//  IOSSecuritySuite
//
//  Created by wregula on 23/04/2019.
//  Copyright © 2019 wregula. All rights reserved.
//

import Foundation
import MachO

public class IOSSecuritySuite {

    /**
     This type method is used to determine the true/false jailbreak status
     
     Usage example
     ```
     let isDeviceJailbroken = IOSSecuritySuite.amIJailbroken() ? true : false
     ```
     */
    public static func amIJailbroken() -> Bool {
        return JailbreakChecker.amIJailbroken()
    }

    /**
     This type method is used to determine the jailbreak status with a message which jailbreak indicator was detected
     
     Usage example
     ```
     let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailMessage()
     if jailbreakStatus.jailbroken {
     print("This device is jailbroken")
     print("Because: \(jailbreakStatus.failMessage)")
     } else {
     print("This device is not jailbroken")
     }
     ```
     
     - Returns: Tuple with with the jailbreak status *Bool* labeled *jailbroken* and *String* labeled *failMessage*
     to determine check that failed
     */
    public static func amIJailbrokenWithFailMessage() -> (jailbroken: Bool, failMessage: String) {
        return JailbreakChecker.amIJailbrokenWithFailMessage()
    }

    /**
    This type method is used to determine the jailbreak status with a list of failed checks

     Usage example
     ```
     let jailbreakStatus = IOSSecuritySuite.amIJailbrokenWithFailedChecks()
     if jailbreakStatus.jailbroken {
     print("This device is jailbroken")
     print("The following checks failed: \(jailbreakStatus.failedChecks)")
     }
     ```

     - Returns: Tuple with with the jailbreak status *Bool* labeled *jailbroken* and *[FailedCheck]* labeled *failedChecks*
     for the list of failed checks
     */
    public static func amIJailbrokenWithFailedChecks() -> (jailbroken: Bool, failedChecks: [FailedCheck]) {
        return JailbreakChecker.amIJailbrokenWithFailedChecks()
    }

    /**
     This type method is used to determine if application is run in emulator
     
     Usage example
     ```
     let runInEmulator = IOSSecuritySuite.amIRunInEmulator() ? true : false
     ```
     */
    public static func amIRunInEmulator() -> Bool {
        return EmulatorChecker.amIRunInEmulator()
    }

    /**
     This type method is used to determine if application is being debugged
     
     Usage example
     ```
     let amIDebugged = IOSSecuritySuite.amIDebugged() ? true : false
     ```
     */
    public static func amIDebugged() -> Bool {
        return DebuggerChecker.amIDebugged()
    }

    /**
     This type method is used to deny debugger and improve the application resillency
     
     Usage example
     ```
     IOSSecuritySuite.denyDebugger()
     ```
     */
    public static func denyDebugger() {
        return DebuggerChecker.denyDebugger()
    }

    /**
     This type method is used to determine if there are any popular reverse engineering tools installed on the device
     
     Usage example
     ```
     let amIReverseEngineered = IOSSecuritySuite.amIReverseEngineered() ? true : false
     ```
     */
    public static func amIReverseEngineered() -> Bool {
        return ReverseEngineeringToolsChecker.amIReverseEngineered()
    }
    
    /**
    This type method is used to determine if `objc call` has been RuntimeHooked by for example `Flex`
     
    Usage example
    ```
     class SomeClass {
        @objc dynamic func someFunction() {
        }
     }
     
    let dylds = ["IOSSecuritySuite", ...]
     
    let amIRuntimeHook = amIRuntimeHook(dyldWhiteList: dylds, detectionClass: SomeClass.self, selector: #selector(SomeClass.someFunction), isClassMethod: false) ? true : false
    ```
     */
    public static func amIRuntimeHooked(dyldWhiteList: [String], detectionClass: AnyClass, selector: Selector, isClassMethod: Bool) -> Bool {
        return RuntimeHookChecker.amIRuntimeHook(dyldWhiteList: dyldWhiteList, detectionClass: detectionClass, selector: selector, isClassMethod: isClassMethod)
    }
}

#if arch(arm64)
public extension IOSSecuritySuite {
    /**
    This type method is used to determine if `function_address` has been hooked by `MSHook`
    
    Usage example
    ```
    func denyDebugger() {
    }
     
    typealias FunctionType = @convention(thin) ()->()
    
    let func_denyDebugger: FunctionType = denyDebugger   // `: FunctionType` is must
    let func_addr = unsafeBitCast(func_denyDebugger, to: UnsafeMutableRawPointer.self)
    let amIMSHookFunction = amIMSHookFunction(func_addr) ? true : false
    ```
    */
    static func amIMSHooked(_ functionAddress: UnsafeMutableRawPointer) -> Bool {
        return MSHookFunctionChecker.amIMSHooked(functionAddress)
    }
    
    /**
    This type method is used to get original `function_address` which has been hooked by  `MSHook`
    
    Usage example
    ```
    func denyDebugger(value: Int) {
    }
     
    typealias FunctionType = @convention(thin) (Int)->()
     
    let funcDenyDebugger: FunctionType = denyDebugger
    let funcAddr = unsafeBitCast(funcDenyDebugger, to: UnsafeMutableRawPointer.self)
     
    if let originalDenyDebugger = denyMSHook(funcAddr) {
        unsafeBitCast(originalDenyDebugger, to: FunctionType.self)(1337) //Call orignal function with 1337 as Int argument
    } else {
        denyDebugger()
    }
    ```
    */
    static func denyMSHook(_ functionAddress: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
        return MSHookFunctionChecker.denyMSHook(functionAddress)
    }
    
    /**
    This type method is used to rebind `symbol` which has been hooked by `fishhook`
     
    Usage example
    ```
    denySymbolHook("$s10Foundation5NSLogyySS_s7CVarArg_pdtF")   // Foudation's NSlog of Swift
    NSLog("Hello Symbol Hook")
     
    denySymbolHook("abort")
    abort()
    ```
     */
    static func denySymbolHook(_ symbol: String) {
        FishHookChecker.denyFishHook(symbol)
    }
    
    /**
    This type method is used to rebind `symbol` which has been hooked  at one of image by `fishhook`
     
    Usage example
    ```
    for i in 0..<_dyld_image_count() {
        if let imageName = _dyld_get_image_name(i) {
            let name = String(cString: imageName)
            if name.contains("IOSSecuritySuite"), let image = _dyld_get_image_header(i) {
                denySymbolHook("dlsym", at: image, imageSlide: _dyld_get_image_vmaddr_slide(i))
                break
            }
        }
    }
    ```
     */
    static func denySymbolHook(_ symbol: String, at image: UnsafePointer<mach_header>, imageSlide slide: Int) {
        FishHookChecker.denyFishHook(symbol, at: image, imageSlide: slide)
    }
}
 #endif
