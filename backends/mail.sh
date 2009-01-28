
####################
#    Copyright (C) 2008 by Raphael Geissert <atomo64@gmail.com>
#
#    This file is part of DeBaBaReTools
#
#    DeBaBaReTools is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    DeBaBaReTools is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with DeBaBaReTools.  If not, see <http://www.gnu.org/licenses/>.
####################

sendMail() {
    local from to body cc bcc subject attachments

    local i
    for i in $(seq 1 $#); do
	case "$1" in
	    -s*)
		subject="${1#-s}"
	    ;;
	    -f*)
		from="${1#-f}"
	    ;;
	    -t*)
		to+="${1#-t},"
	    ;;
	    -c*)
		cc+="${1#-c},"
	    ;;
	    -bc*)
		bcc+="${1#-bc},"
	    ;;
	    -a*)
		attachments+="${1#-a}|"
	    ;;
	    -b*)
		body+="${1#-b}"
	    ;;
	esac
	shift
    done

    [ ${#attachments} -eq 0 ] || \
    attachments=${attachments:0:${#attachments}-1}
    local f
    for f in to cc bcc; do
	[ ${#$f} -eq 0 ] || \
	$f=${$f:0:${#$f}-1}
    done

    if [ -z "$body" ]; then
	body="$(cat)"
    fi

    local mailfile="$(mktemp)" _IFS="$IFS"
    local boundary="$(echo "$RANDOM$RANDOM$RANDOM" | sha1sum | cut '-d ' -f1)"
    IFS='|'

    printf '' > $mailfile
    printf "From: %s\n" "$from" >> $mailfile
    printf "To: %s\n" "$to" >> $mailfile
    [ "$cc" ] &&  printf "Cc: %s\n" "$cc" >> $mailfile
    [ "$bcc" ] && printf "Bcc: %s\n" "$bcc" >> $mailfile
    printf "Subject: %s\n" "$subject" >> $mailfile
    printf "Message-ID: <%d-%d-%d@%s>\n" \
		"$RANDOM" \
		"$(date +%Y%m%d%H%M%S)" \
		"$RANDOM" \
		"$HOSTNAME" >> $mailfile
    printf "Mime-Version: 1.0\n" >> $mailfile
    printf 'Content-Type: multipart/mixed; boundary="%s"\n' \
		"$boundary" >> $mailfile
    printf "Content-Disposition: inline\n" >> $mailfile
    printf "X-Mailer: DeBaBaReTools Mail backend 0.1\n" >> $mailfile
    printf "\n\n" >> $mailfile

    printf "%s\n" "--$boundary" >> $mailfile
    printf "Content-Type: text/plain; charset=utf-8\n" >> $mailfile
    printf "Content-Disposition: inline\n" >> $mailfile
    printf "\n%s\n" "$body" >> $mailfile

    local atta type
    for atta in $attachments; do
	[ -e "$atta" ] || continue
	type="$(file -bi -- "$atta")"
	type=${type/,*;/;}
	type=${type/%,*/}
	printf "%s\n" "--$boundary" >> $mailfile
	printf "Content-Type: %s\n" "${type:-application/unknown}" >> $mailfile
	printf 'Content-Disposition: attachment; filename="%s"\n' \
		    "$(basename "$atta")" >> $mailfile
	printf "Content-Transfer-Encoding: base64\n" >> $mailfile
	echo >> $mailfile
	base64 "$atta" >> $mailfile
	echo >> $mailfile
    done

    printf "%s\n" "--$boundary--" >> $mailfile

    local es=0
    /usr/sbin/sendmail -t < $mailfile || es=$?

    rm -f $mailfile

    IFS="${_IFS}"
    return $es
}
