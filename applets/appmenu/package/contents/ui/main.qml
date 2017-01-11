/*
 * Copyright 2013  Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2016 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.appmenu 1.0 as AppMenuPrivate

Item {
    id: root

    readonly property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    readonly property bool compactView: plasmoid.configuration.compactView

    onCompactViewChanged: {
        plasmoid.nativeInterface.view = compactView
    }

    Layout.minimumWidth: units.gridUnit
    Layout.minimumHeight: units.gridUnit

    Plasmoid.preferredRepresentation: plasmoid.configuration.compactView ? Plasmoid.compactRepresentation : Plasmoid.fullRepresentation

    Plasmoid.compactRepresentation: PlasmaComponents.ToolButton {
        Layout.fillWidth: false
        Layout.fillHeight: false
        Layout.minimumWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        text: i18n("Menu")
        onClicked: {
            plasmoid.nativeInterface.trigger(this, 0);
        }
    }

    Plasmoid.fullRepresentation: GridLayout {
        id: buttonGrid
        Layout.fillWidth: !root.vertical
        Layout.fillHeight: root.vertical
        flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rowSpacing: units.smallSpacing
        columnSpacing: units.smallSpacing

        Component.onCompleted: {
            plasmoid.nativeInterface.buttonGrid = buttonGrid
        }

        Connections {
            target: plasmoid.nativeInterface
            onRequestActivateIndex: {
                var idx = Math.max(0, Math.min(buttonRepeater.count - 1, index))
                var button = buttonRepeater.itemAt(index)
                if (button) {
                    button.clicked()
                }
            }
        }

        Repeater {
            id: buttonRepeater
            model: appMenuModel

            PlasmaComponents.ToolButton {
                readonly property int buttonIndex: index

                Layout.preferredWidth: minimumWidth
                Layout.fillWidth: root.vertical
                Layout.fillHeight: !root.vertical
                text: activeMenu
                // fake highlighted
                checkable: plasmoid.nativeInterface.currentIndex === index
                checked: checkable
                onClicked: {
                    plasmoid.nativeInterface.trigger(this, index)
                }
            }
        }
    }

    AppMenuPrivate.AppMenuModel {
        id: appMenuModel
        Component.onCompleted: {
            plasmoid.nativeInterface.model = appMenuModel
        }
    }

    Connections {
        target: appMenuModel
        onResetModel: {
            plasmoid.nativeInterface.model = appMenuModel
        }
    }
}