//
//  RewiredExample.cs
//  NCGameControllerUnity
//
//  Created by Ben Schmidt on 2021-01-6.
//  Shout out to Joon
//  Copyright © 2021 Noodlecake Studios Inc. All rights reserved.
//

//NOTE: this is a heavily stripped down file from a real game.
//It is for example purposes only and is not intended to be used as a drop-in solution.
//You can use this as a reference of how to modify your existing rewired input handler class.
//If you make a proper drop-in solution please consider making a pull request to share :)

using System;
using Rewired;
using UnityEngine;

#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
using static NCGameControllerUnity;
#endif

public class InputHelper : MonoBehaviour
{        
    public static Rewired.Player player { get { return ReInput.players.GetPlayer(0); } }

#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
    private static InputHelper inputHelperInstance;
    private static CustomController appleVirtualController;
#endif

    //the game this code was in had an special singleton awake system but I think it will work in a normal MonoBehaviour
    public void Awake()
    {
        player.controllers.ControllerAddedEvent += OnControllerAdded;

#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
        if (appleVirtualController != null) {
            InitializeLayout(appleVirtualController);
        }
#endif
    }

    public void OnDestroy()
    {
        //the game this code was in had a weird singleton class that messed up if I modified OnDestroy
        //but I think you should set appleVirtualController to null here
    }

    private void InitializeLayout(Controller controller)
    {
        if(SceneLoadManager.i.IsLoading()) return;
        
        if (!controller.enabled)
        {
            return;
        }
        
        if (!player.controllers.ContainsController(controller))
        {
            Debug.Log("ChangeLayout: Controller is not assigned to player!");
            return;
        }

        //remove and load controller maps as necessary here
    }

    void OnControllerAdded(ControllerAssignmentChangedEventArgs obj)
    {
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
        // if you don't remove the "actual" controller you'll get input twice
        if (obj.controller.type == ControllerType.Joystick) {
            player.controllers.RemoveController(obj.controller);
            ConnectAppleController();
            return;
        } else if (appleVirtualController != null) {
            InitializeLayout(appleVirtualController);
        }
#endif
    }

    void Start()
    {
        if(ReInput.userDataStore!=null)
            ReInput.userDataStore.Load();
        
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
        inputHelperInstance = this;
        NCGameControllerUnity.RegisterControllerConnectedCallback(OnAppleControllerConnected);
        NCGameControllerUnity.RegisterControllerDisconnectedCallback(OnAppleControllerDisconnected);
        appleVirtualController = null;
#endif
    }

    public void ResetRewired()
    {
        ReInput.Reset();

#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
        appleVirtualController = null;
#endif
    }

#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
    private void ConnectAppleController() {
        if(!Application.isPlaying) return;

        //NOTE: You can probably chage this to "DeviceHasControllerConnected()" if your game can support a mini controller (2 buttons + dpad)
        if (NCGameControllerUnity.DeviceHasExtendedControllerConnected()) {
            if (appleVirtualController == null || !appleVirtualController.enabled){

                //NOTE: this assumes that your custom controller is index 1 in your list of custom controllers in the rewired editor
                appleVirtualController = ReInput.controllers.CreateCustomController(1, "apple");

                NCGameControllerUnity.RegisterControllerInputCallback(OnAppleControllerInput);
            }
            
            player.controllers.AddController(appleVirtualController, true);
        }
    }

    [AOT.MonoPInvokeCallback(typeof(NCControllerInputDelgate))]
    private static void OnAppleControllerInput(int id, float val1, float val2) {
        if(!Application.isPlaying) return;
        
        if (appleVirtualController == null) {
            return;
        }

        if (id >= 0 && id < Enum.GetNames(typeof(NCControlElementID)).Length) {
            //Debug.Log("Apple Controller Input! ID: " + ((NCControlElementID)id).ToString("g") + "   val1: " + val1 + "   val2: " + val2);

            NCControlElementID elemID = (NCControlElementID)id;

            switch (elemID)
            {
                case NCControlElementID.ButtonA:
                    appleVirtualController.SetButtonValue(0, val2 != 0);
                    break;
                case NCControlElementID.ButtonB:
                    appleVirtualController.SetButtonValue(1, val2 != 0);
                    break;
                case NCControlElementID.ButtonX:
                    appleVirtualController.SetButtonValue(2, val2 != 0);
                    break;
                case NCControlElementID.ButtonY:
                    appleVirtualController.SetButtonValue(3, val2 != 0);
                    break;
                case NCControlElementID.ButtonShoulderLeft:
                    appleVirtualController.SetButtonValue(4, val2 != 0);
                    break;
                case NCControlElementID.ButtonShoulderRight:
                    appleVirtualController.SetButtonValue(5, val2 != 0);
                    break;
                case NCControlElementID.ButtonTriggerLeft:
                    appleVirtualController.SetButtonValue(6, val2 != 0);
                    appleVirtualController.SetAxisValue(6, val1);
                    break;
                case NCControlElementID.ButtonTriggerRight:
                    appleVirtualController.SetButtonValue(7, val2 != 0);
                    appleVirtualController.SetAxisValue(7, val2);
                    break;
                case NCControlElementID.ButtonHome:
                    appleVirtualController.SetButtonValue(8, val2 != 0);
                    break;
                case NCControlElementID.ButtonMenu:
                    appleVirtualController.SetButtonValue(9, val2 != 0);
                    break;
                case NCControlElementID.ButtonOptions:
                    appleVirtualController.SetButtonValue(10, val2 != 0);
                    break;
                case NCControlElementID.ButtonUp:
                    appleVirtualController.SetButtonValue(11, val2 != 0);
                    break;
                case NCControlElementID.ButtonDown:
                    appleVirtualController.SetButtonValue(12, (val2 != 0));
                    break;
                case NCControlElementID.ButtonLeft:
                    appleVirtualController.SetButtonValue(13, val2 != 0);
                    break;
                case NCControlElementID.ButtonRight:
                    appleVirtualController.SetButtonValue(14, val2 != 0);
                    break;
                case NCControlElementID.ButtonThumbstickLeft:
                    appleVirtualController.SetButtonValue(15, val2 != 0);
                    break;
                case NCControlElementID.ButtonThumbstickRight:
                    appleVirtualController.SetButtonValue(16, val2 != 0);
                    break;
                case NCControlElementID.Dpad:
                    appleVirtualController.SetAxisValue(0, val1);
                    appleVirtualController.SetAxisValue(1, val2);
                    break;
                case NCControlElementID.ThumbstickLeft:
                    appleVirtualController.SetAxisValue(2, val1);
                    appleVirtualController.SetAxisValue(3, val2);
                    break;
                case NCControlElementID.ThumbstickRight:
                    appleVirtualController.SetAxisValue(4, val1);
                    appleVirtualController.SetAxisValue(5, val2);
                    break;
                default:
                    break;
            }
        }
    }

    [AOT.MonoPInvokeCallback(typeof(NCControllerConnectedDelgate))]
    private static void OnAppleControllerConnected()
    {
        if(!Application.isPlaying) return;
        inputHelperInstance.ConnectAppleController();
    }

    [AOT.MonoPInvokeCallback(typeof(NCControllerDisconnectedDelgate))]
    private static void OnAppleControllerDisconnected()
    {
        if(!Application.isPlaying) return;
        player.controllers.RemoveController(appleVirtualController);
        appleVirtualController = null;
    }
#endif

}
