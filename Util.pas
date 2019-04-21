unit Util;

interface
	uses
		Database;
	function hashCode(s: string): int64;
	function parseInt(s: string): int64;
	function toString(i: integer): string;
	function getTanggal(s: string): Tanggal;
	function tanggalToString(t: Tanggal): string;
	function hitungHari(from, next: Tanggal): int64;
	function toCSV(s: string): string;
	function fromCSV(s: string): string;
	procedure sortBukuData(var data: DataBuku);
	function findBuku(id: integer): Buku;
	function findPinjam(id: integer; username: string): Pinjam;
	function findUser(username: string): User;
	function isKategoriValid(s: string): boolean;
	function get1WeekAfter(t: Tanggal): Tanggal;
	function getKategoriID(kat: string): integer;
	function isPengunjung(u: User): boolean;
	function isAdmin(u: User): boolean;
	function columnCount(s: string): integer;
	function getKategoriString: string;

implementation
	function hashCode(s: string): int64;
		const
			HASH_PRIME = 31;
		var
			res: int64;
			i: longint;
		begin
			res := 0;
			for i := 1 to length(s) do
				res := res*HASH_PRIME + ord(s[i]);
			hashCode := res;
		end;
	function parseInt(s: string): int64;
		var
			i: integer;
			neg: boolean;
		begin
			parseInt := 0;
			neg := false;
			for i := 1 to length(s) do begin
				if (not neg) and (s[i] = '-') then
					neg := true
				else
					parseInt := parseInt*10 + (ord(s[i])-ord('0'));
			end;
			if neg then
				parseInt := -parseInt;
		end;
	function toString(i: integer): string;
		var
			neg: boolean;
		begin
			toString := '';
			neg := false;
			if (i < 0) then begin
				neg := true;
				i := -i;
			end;
			if i = 0 then
				toString := '0';
			while i > 0 do begin
				toString := chr(ord('0') + (i mod 10)) + toString;
				i := i div 10;
			end;
			if neg then
				toString := '-' + toString;
		end;
	function isKabisat(y: integer): boolean;
		begin
			isKabisat := (y mod 4 = 0) and ((y mod 100 <> 0) or (y mod 400 = 0));
		end;
	function isNewer(t1, t2: Tanggal): boolean;
		begin
			if (t1.y = t2.y) then
				if (t1.m = t2.m) then
					isNewer := t1.d >= t2.d
				else
					isNewer := t1.m > t2.m
			else
				isNewer := t1.y > t2.y;
		end;
	function dayInMonth(m, y: integer): integer;
		begin
			if (m = 2) then
				if isKabisat(y) then
					dayInMonth := 29
				else
					dayInMonth := 28
			else if ((m <= 7) and (m mod 2 = 0)) or ((m > 7) and (m mod 2 = 1)) then
				dayInMonth := 30
			else
				dayInMonth := 31;
		end;
	function getTanggal(s: string): Tanggal;
		var
			res: Tanggal;
			read: string;
			i: integer;
		begin
			i := 1;
			read := '';
			while (s[i] <> '/') do begin
				read := read + s[i];
				i := i + 1;
			end;
			res.d := parseInt(read);
			read := '';
			i := i + 1;
			while (s[i] <> '/') do begin
				read := read + s[i];
				i := i + 1;
			end;
			res.m := parseInt(read);
			read := '';
			i := i + 1;
			while (i <= length(s)) do begin
				read := read + s[i];
				i := i + 1;
			end;
			res.y := parseInt(read);
			getTanggal := res;
		end;
	function tanggalToString(t: Tanggal): string;
		var
			s: string;
		begin
			tanggalToString := toString(t.d);
			if length(tanggalToString) < 2 then
				tanggalToString := '0' + tanggalToString;
			s := toString(t.m);
			if length(s) < 2 then
				s := '0' + s;
			tanggalToString := tanggalToString + '/' + s + '/' + toString(t.y);
		end;
	function hitungHari(from, next: Tanggal): int64;
		var
			i, min: integer;
			a, b: Tanggal;
		begin
			hitungHari := 0;
			if (isNewer(from, next)) then begin
				a := next;
				b := from;
			end else begin
				a := from;
				b := next;
			end;
			min := dayInMonth(b.m, b.y) - b.d + a.d;
			for i := b.m+1 to 12 do
				min := min + dayInMonth(i, b.y);
			for i := a.m-1 downto 1 do
				min := min + dayInMonth(i, a.y);
			hitungHari := 0;
			for i := a.y to b.y do
				if isKabisat(i) then
					hitungHari := hitungHari + 366
				else
					hitungHari := hitungHari + 365;
			hitungHari := hitungHari - min;
		end;
	function toCSV(s: string): string;
		var
			i: integer;
			c: char;
		begin
			toCSV := s;
			for c in s do
				if (c = ',') then begin
					toCSV := '"' + s + '"';
					break;
				end;
		end;
	function fromCSV(s: string): string;
		var
			i: integer;
		begin
			if (s[1] = '"') and (s[length(s)] = '"') then begin
				fromCSV := '';
				for i := 2 to length(s)-1 do
					fromCSV += s[i];
			end else
				fromCSV := s;
		end;
	procedure merge(data1, data2: DataBuku; var data: DataBuku);
		var
			l1, l2, a, b, i: integer;
		begin
			l1 := data1.length;
			l2 := data2.length;
			a := 0;
			b := 0;
			i := 0;
			while (a < l1) and (b < l2) do begin
				if (data1.arr[a].judul < data2.arr[b].judul) then begin
					data.arr[i] := data1.arr[a];
					i += 1;
					a += 1;
				end else begin
					data.arr[i] := data2.arr[b];
					i += 1;
					b += 1;
				end;
			end;
			while (a < l1) do begin
				data.arr[i] := data1.arr[a];
				i += 1;
				a += 1;
			end;
			while (b < l2) do begin
				data.arr[i] := data2.arr[b];
				i += 1;
				b += 1;
			end;
		end;
	procedure sortBukuData(var data: DataBuku);
		var
			data1, data2: DataBuku;
			l, i, half: integer;
		begin
			l := data.length;
			half := l div 2;
			if (l > 1) then begin
				data1.length := half;
				data2.length := l-half;
				for i := 1 to half do
					data1.arr[i] := data.arr[i];
				for i := half+1 to l do
					data2.arr[i-half] := data.arr[i];
				sortBukuData(data1);
				sortBukuData(data2);
				merge(data1, data2, data);
			end;
		end;
	function findBuku(id: integer): Buku;
		var
			b: Buku;
		begin
			for b in bukuData.arr do
				if b.id = id then begin
					findBuku := b;
					break;
				end;
		end;
	function findPinjam(id: integer; username: string): Pinjam;
		var
			ph: Pinjam;
		begin
			for ph in pinjamData.arr do
				if (ph.id = id) and (ph.username = username) then begin
					findPinjam := ph;
					break;
				end;
		end;
	function findUser(username: string): User;
		var
			u: User;
		begin
			for u in userData.arr do
				if (u.username = username) then begin
					findUser := u;
					break;
				end;
		end;
	function isKategoriValid(s: string): boolean;
		var
			kat: string;
		begin
			isKategoriValid := false;
			for kat in validKategori do
				if (kat = s) then begin
					isKategoriValid := true;
					break;
				end;
		end;
	function get1WeekAfter(t: Tanggal): Tanggal;
		var
			max: integer;
		begin
			max := dayInMonth(t.m, t.y);
			t.d := t.d + 7;
			if (t.d > max) then begin
				t.d := t.d - max;
				t.m += 1;
				if (t.m > 12) then begin
					t.m := t.m - 12;
					t.y += 1;
				end;
			end;
			get1WeekAfter := t;
		end;
	function getKategoriID(kat: string): integer;
		var
			i: integer;
		begin
			for i := 1 to 5 do
				if (validKategori[i] = kat) then
					break;
			if (validKategori[i] = kat) then
				getKategoriID := i
			else
				getKategoriID := -1;
		end;
	function isPengunjung(u: user): boolean;
		begin
			isPengunjung := (u.role = ROLE_PENGUNJUNG);
		end;
	function isAdmin(u: user): boolean;
		begin
			isAdmin := (u.role = ROLE_ADMIN);
		end;
	function columnCount(s: string): integer;
		var
			c: char;
		begin
			columnCount := 1;
			if (length(s) <= 0) then
				columnCount := 0
			else
				for c in s do
					if c = ',' then
						columnCount += 1;
		end;
	function getKategoriString: string;
		var
			i: integer;
		begin
			getKategoriString := validKategori[1];
			for i := 2 to length(validKategori) do
				getKategoriString += ', ' + validKategori[i];
		end;
	procedure writeBukuNotFound(id: integer);
		begin
			writeln('Buku dengan ID: ', id, ' tidak ditemukan');
		end;
	
end.