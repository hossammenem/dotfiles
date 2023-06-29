import dbus
import math

CHAR = ""
LENGTH = 25


def format_time(microseconds):
    sec, _ = divmod(microseconds, 1e6)

    mm, ss = divmod(sec, 60)
    hh, mm = divmod(mm, 60)

    hh_str = f"{int(hh):02d}:" if hh > 0 else ""

    return f"{hh_str}{int(mm):02d}:{int(ss):02d}"


def main():
    try:
        session_bus = dbus.SessionBus()
        spotify_bus = session_bus.get_object(
            'org.mpris.MediaPlayer2.spotify',
            '/org/mpris/MediaPlayer2'
        )

        spotify_properties = dbus.Interface(
            spotify_bus,
            'org.freedesktop.DBus.Properties'
        )

        metadata = spotify_properties.Get(
            'org.mpris.MediaPlayer2.Player', 'Metadata'
        )
        track_len = metadata['mpris:length']
        position = spotify_properties.Get(
            'org.mpris.MediaPlayer2.Player', 'Position'
        )

        time_per_char = track_len / LENGTH
        progress = 0

        if position > time_per_char:
            progress = math.ceil(position / time_per_char)

        remaining = LENGTH - progress

        bar = f"{format_time(position)}  %{{F#94e2d5}}{CHAR * progress}%{{F#313244}}{CHAR * remaining}  %{{F#74c7ec}}{format_time(track_len)}"

        print(bar)
    except Exception as e:
        if isinstance(e, dbus.exceptions.DBusException):
            print('')
        else:
            print(e)


if __name__ == "__main__":
    main()
