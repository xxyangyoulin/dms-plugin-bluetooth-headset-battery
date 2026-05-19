import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property var headsets: BluetoothService.allDevicesWithBattery.filter(device => {
        return device.connected && BluetoothService.isAudioDevice(device)
    })
    readonly property var primaryHeadset: headsets.length > 0 ? headsets[0] : null
    readonly property int primaryBattery: primaryHeadset ? Math.round(primaryHeadset.battery * 100) : 0
    readonly property bool hasHeadset: primaryHeadset !== null

    ccWidgetIcon: hasHeadset ? BluetoothService.getDeviceIcon(primaryHeadset) : "headset_off"
    ccWidgetPrimaryText: hasHeadset ? deviceName(primaryHeadset) : "Bluetooth Headset"
    ccWidgetSecondaryText: hasHeadset ? `${primaryBattery}%` : "No connected headset"
    ccWidgetIsActive: hasHeadset
    ccWidgetIsToggle: false

    popoutWidth: 360
    popoutHeight: 220

    Component.onCompleted: setVisibilityOverride(hasHeadset)
    onHasHeadsetChanged: setVisibilityOverride(hasHeadset)

    function deviceName(device) {
        return device ? (device.name || device.deviceName || device.address || "Bluetooth headset") : "Bluetooth headset"
    }

    function batteryColor(percent) {
        if (percent <= 20)
            return Theme.error
        if (percent <= 40)
            return Theme.warning
        return Theme.primary
    }

    function batteryIcon(percent) {
        return Theme.getBatteryIcon(percent, false, true)
    }

    horizontalBarPill: Component {
        Row {
            visible: root.hasHeadset
            width: visible ? implicitWidth : 0
            height: visible ? implicitHeight : 0
            spacing: Theme.spacingXS

            DankIcon {
                name: root.hasHeadset ? BluetoothService.getDeviceIcon(root.primaryHeadset) : "headset_off"
                color: root.batteryColor(root.primaryBattery)
                size: root.iconSize
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: `${root.primaryBattery}%`
                color: Theme.surfaceText
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            visible: root.hasHeadset
            width: visible ? implicitWidth : 0
            height: visible ? implicitHeight : 0
            spacing: Theme.spacingXS

            DankIcon {
                name: root.hasHeadset ? BluetoothService.getDeviceIcon(root.primaryHeadset) : "headset_off"
                color: root.batteryColor(root.primaryBattery)
                size: root.iconSize
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: `${root.primaryBattery}`
                color: Theme.surfaceText
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            showCloseButton: false

            Column {
                width: parent.width
                spacing: Theme.spacingS

                Repeater {
                    model: root.headsets

                    delegate: StyledRect {
                        width: parent.width
                        height: 56
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainer

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            spacing: Theme.spacingM

                            DankIcon {
                                name: BluetoothService.getDeviceIcon(modelData)
                                color: root.batteryColor(Math.round(modelData.battery * 100))
                                size: Theme.iconSize
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                width: parent.width - batteryText.width - Theme.iconSize - Theme.spacingM * 2
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    width: parent.width
                                    text: root.deviceName(modelData)
                                    color: Theme.surfaceText
                                    font.pixelSize: Theme.fontSizeMedium
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    width: parent.width
                                    text: modelData.address || ""
                                    color: Theme.surfaceVariantText
                                    font.pixelSize: Theme.fontSizeSmall
                                    elide: Text.ElideRight
                                }
                            }

                            StyledText {
                                id: batteryText
                                text: `${Math.round(modelData.battery * 100)}%`
                                color: root.batteryColor(Math.round(modelData.battery * 100))
                                font.pixelSize: Theme.fontSizeLarge
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                StyledText {
                    width: parent.width
                    visible: !root.hasHeadset
                    text: "Connect a Bluetooth headset that reports battery level."
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
