![Logo](./images/avfx-mosyle-dark.png#gh-dark-mode-only)
![Logo](./images/avfx-mosyle-light.png#gh-light-mode-only)

# 💻 AVFX Mosyle MDM Deployment Documentation

This repository documents our organization's **Mobile Device Management (MDM)** implementation using **Mosyle MDM** for macOS and iOS devices. It includes application lists, configuration profiles, enrollment procedures, automated scripts, and operational workflows used to manage and secure our Apple device fleet.

---

## 📘 Table of Contents

1. [Overview](#overview)
2. [Goals](#goals)
3. [Mosyle Configuration](#mosyle-configuration)
4. [Device Enrollment Process](#device-enrollment-process)
5. [Configuration Profiles](#configuration-profiles)
6. [Application Deployment](#application-deployment)
7. [Automation & Scripts](#automation--scripts)
8. [User Experience](#user-experience)
9. [Security & Compliance](#security--compliance)
10. [Maintenance & Updates](#maintenance--updates)
11. [Troubleshooting](#troubleshooting)

---

## 📋 Overview

Mosyle is our current MDM provieder. We use it to automatically provision macOS and iOS devices for event operations and employees.

---

## 🎯 Goals

- Zero-touch device provisioning using Apple Business Manager (ABM)
- Seamless user onboarding with pre-configured settings
- Automated app and profile deployment
- Warehouse operations deployment of event devices
- Enforce compliance through restrictions and policies
- Ongoing security and OS update management

---

## 🛠️ Mosyle Configuration

- **Platform:** Mosyle Business (or Manager)
- **Integration:** Apple Business Manager (ABM), VPP, DEP
- **Device Types Managed:** macOS, iOS/iPadOS
- **Groups & Tags:** Device groups determine which profiles, apps or settings are installed on a device
- **Deployment Scripts & Tools:** Tools to streamline our deployment for a workflow and customized experience

---

## 🚀 Device Enrollment Process

1. **Device Assigned via ABM**

   - Devices are added to Mosyle via Apple Business Manager (ABM) Automated Device Enrollment (ADE). All devices inside our ABM account are by default assigned to Mosyle as the MDM server.

2. **Enrollment Profiles**

   - There are several device enrollment profiles that Mosyle deploys for us. They are as follows by device:
     - macOS:
       - AVFX-Employee (default profile for macOS)
       - AVFX-EventOps (manually assigned by serial number)
       - MDM Testing (used to test enrollment and new configurations)
     - iOS:
       - AVFX-Employee (Default profile for iOS)
       - AVFX-EventOps (Manually assigned by serial number)

3. **Enrollment Process**

   - When devices initially boot they require being connected to the internet.
   - Once connected they will communicate with ABM and determine that this device is managed.
   - It will prompt the user to click "Enroll".
   - Mosyle will deliver the enrollment profile based on the serial number of the device.

4. **Setup Assistant Configuration**

   - Depending on the enrollment profile a user will be show setup assistant screens.
   - Devices assigned to AVFX-EventOps will not display options for setup.

5. **Post-Enrollment Tasks**
   - A default user will be installed

---

## 🧾 Configuration Profiles

| Profile Name          | Target Group   | Purpose                          |
| --------------------- | -------------- | -------------------------------- |
| Wi-Fi Configuration   | All Staff Macs | Auto-connect to corp SSID        |
| Restrictions          | Student iPads  | Limit App Store, Safari          |
| FileVault Enforcement | All macOS      | Enforce disk encryption          |
| PPPC Settings         | Admin Devices  | Pre-approve security permissions |
| Dock Configuration    | Marketing Macs | Standardize application layout   |

> All custom profiles are exported as `.mobileconfig` and stored in `/profiles`.

---

## 📦 Application Deployment

- **VPP (Volume Purchase Program)** is used to assign apps to devices from the App Store.
- **Custom Apps** are deployed using `.pkg` files uploaded to Mosyle or via Installomator & Homebrew
- **Auto-Update Settings:** Apps are configured to auto-update when possible.

---

## Applications Included by Device and Enrollment Profile

### macOS

| Application                         | Description                 | AVFX-EventOps | AVFX-Employee | Install Source |
| ----------------------------------- | --------------------------- | ------------- | ------------- | -------------- |
| Microsoft Office for Mac            | Powerpoint, Word and Excell | ✅ Yes        | ✅ Yes        | Installomator  |
| Microsoft Office for Mac Serializer | Licensing for Office        | ✅ Yes        | ❌ No         | Baseline       |
| Keynote                             | Apple Slide Application     | ✅ Yes        | ❌ No         | Apple VPP      |
| Homebrew 🍺                         | CLI Package Manager         | ✅ Yes        | ✅ Yes        | Installomator  |
| Google Chrome                       | Web Browser                 | ✅ Yes        | ✅ Yes        | Installomator  |
| Handbrake                           | Media Conversion Tool       | ✅ Yes        | ❌ No         | Installomator  |
| Zoom                                | Video Conferencing          | ✅ Yes        | ❌ No         | Installomator  |
| Adobe Acrobat Reader                | PDF Reader                  | ✅ Yes        | ❌ No         | Installomator  |
| QLab                                | Video Playback Software     | ✅ Yes        | ❌ No         | Installomator  |
| Mitti                               | Video Playback Software     | ✅ Yes        | ❌ No         | Homebrew       |
| Playback Pro (IA and Hardware Key)  | Video Playback Software     | ✅ Yes        | ❌ No         | CLI Script     |
| Unity Client                        | Online Comms                | ✅ Yes        | ❌ No         | Apple VPP      |
| Teleprompter                        | Prompter App                | ✅ Yes        | ❌ No         | Apple VPP      |
| Companion                           | StreamDeck App              | ✅ Yes        | ❌ No         | Homebrew       |
| VLC                                 | Media Player                | ✅ Yes        | ❌ No         | Installomator  |
| ffmpeg                              | CLI Video / Audio Tool      | ✅ Yes        | ❌ No         | Homebrew       |
| yt-dlp                              | CLI Youtube Download        | ✅ Yes        | ❌ No         | Homebrew       |

### iOS

No specific applications are installed for iOS devices for employees or rental at this time.

## ⚙️ Automation & Scripts

| Script Name           | Trigger Event    | Description                        |
| --------------------- | ---------------- | ---------------------------------- |
| `set-darkmode.sh`     | First Login      | Sets macOS dark mode for new users |
| `install-homebrew.sh` | On Demand        | Installs Homebrew package manager  |
| `baseline-setup.sh`   | After Enrollment | Runs baseline configurations       |

Scripts are stored in `/scripts` with execution permissions and usage notes.

---

## 👤 User Experience

- Users receive a pre-configured device with minimal setup required.
- Optional onboarding PDF or Swift Dialog UI can be included during first login.
- Desktop shortcuts and dock are pre-configured based on department tag.

---

## 🔐 Security & Compliance

- **FileVault** enabled on all macOS devices
- **Password Policy** enforced via configuration profile
- **Remote Wipe/Lock** enabled through Mosyle dashboard
- **OS Updates** managed via update policies

---

## 🔄 Maintenance & Updates

- **Profile Review:** Quarterly review of all configuration profiles
- **App Inventory:** Auto-inventory and licensing tracking
- **OS Patching:** Monthly update campaigns triggered via Mosyle

---

## 🧯 Troubleshooting

| Issue                   | Resolution                               |
| ----------------------- | ---------------------------------------- |
| App not installing      | Check VPP assignment and device tagging  |
| Profile not applying    | Confirm device group membership and sync |
| Device not checking in  | Reboot or force a check-in from Mosyle   |
| PPPC permissions denied | Ensure correct CodeRequirement string    |

---

## 📎 Resources

- [Mosyle Admin Guide](https://business.mosyle.com/docs/)
- [Apple Platform Deployment](https://support.apple.com/guide/deployment/)
- [Swift Dialog](https://github.com/bartreardon/swiftDialog)
