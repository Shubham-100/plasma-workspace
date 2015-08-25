/********************************************************************
 KSld - the KDE Screenlocker Daemon
 This file is part of the KDE project.

Copyright (C) 1999 Martin R. Jones <mjones@kde.org>
Copyright (C) 2002 Luboš Luňák <l.lunak@kde.org>
Copyright (C) 2003 Oswald Buddenhagen <ossi@kde.org>
Copyright (C) 2008 Chani Armitage <chanika@gmail.com>
Copyright (C) 2011 Martin Gräßlin <mgraesslin@kde.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
#ifndef SCREENLOCKER_LOCKWINDOW_H
#define SCREENLOCKER_LOCKWINDOW_H
#include <QAbstractNativeEventFilter>
#include <QRasterWindow>
#include <X11/Xlib.h>
#include <fixx11h.h>

class QTimer;

class GlobalAccel;

namespace ScreenLocker
{

class LockWindow;

class BackgroundWindow : public QRasterWindow
{
    Q_OBJECT
public:
    explicit BackgroundWindow(LockWindow *lock);
    virtual ~BackgroundWindow();

protected:
    void paintEvent(QPaintEvent *) override;

private:
    LockWindow *m_lock;
};

class LockWindow : public QObject, public QAbstractNativeEventFilter
{
    Q_OBJECT
public:
    LockWindow();
    virtual ~LockWindow();

    void showLockWindow();
    void hideLockWindow();

    void addAllowedWindow(quint32 window);

    void setGlobalAccel(GlobalAccel *ga) {
        m_globalAccel = ga;
    }

    virtual bool nativeEventFilter(const QByteArray &eventType, void *message, long *result) override;

Q_SIGNALS:
    void userActivity();

private Q_SLOTS:
    void updateGeo();

private:
    void initialize();
    void saveVRoot();
    void setVRoot(Window win, Window vr);
    void removeVRoot(Window win);
    int findWindowInfo(Window w);
    void stayOnTop();
    struct WindowInfo
    {
        Window window;
        bool viewable;
    };
    QList<WindowInfo> m_windowInfo;
    QList<WId> m_lockWindows;
    QList<quint32> m_allowedWindows;
    GlobalAccel *m_globalAccel = nullptr;
    QScopedPointer<BackgroundWindow> m_background;
    friend class BackgroundWindow;
};
}

#endif // SCREENLOCKER_LOCKWINDOW_H
