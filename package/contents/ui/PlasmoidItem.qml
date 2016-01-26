/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: plasmoidContainer
    height: hidden ? root.hiddenItemSize : root.itemSize
    width: labelVisible ? parent.width : height
    property Item applet
    property bool hidden: applet.parent.parent.objectName == "hiddenTasksColumn"
    property bool labelVisible: plasmoidContainer.hidden && !root.activeApplet
    hoverEnabled: true

    onEntered: {
        if (hidden) {
            root.hiddenLayout.hoveredItem = plasmoidContainer
        }
    }
    onClicked: {
        applet.expanded = true;
    }
    onHeightChanged: {
        applet.width = height
    }

    Connections {
        target: applet
        onExpandedChanged: {
            if (expanded) {
                var oldApplet = root.activeApplet;
                root.activeApplet = applet;
                if (oldApplet) {
                    oldApplet.expanded = false;
                }
                dialog.visible = true;

            } else if (root.activeApplet == applet) {
                if (!applet.parent.hidden) {
                    dialog.visible = false;
                }
                //if not expanded we don't have an active applet anymore
                root.activeApplet = null;
            }
        }

        onStatusChanged: {
            if (applet.status == PlasmaCore.Types.PassiveStatus) {
                plasmoidContainer.parent = hiddenLayout;
                plasmoidContainer.x = 0;
            } else {
                plasmoidContainer.parent = visibleLayout;
            }
        }
    }

    PlasmaComponents.Label {
        opacity: labelVisible ? 1 : 0
        x: applet.width + units.smallSpacing
        Behavior on opacity {
            NumberAnimation {
                duration: units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        anchors {
            verticalCenter: parent.verticalCenter
        }
        text: applet.title
    }
}
