unit Database;

interface
	const
		NMAX = 1000;
		ROLE_PENGUNJUNG = 'Pengunjung';
		ROLE_ADMIN = 'Admin';

	type
		Tanggal = record
			d, m, y: integer;
		end;
		User = record
			nama, alamat, username, role: string;
			password: int64;
		end;
		Buku = record
			id, jumlah, tahun: integer;
			judul, author, kategori: string;
		end;
		Pinjam = record
			username: string;
			id: integer;
			status: boolean;
			tanggalPinjam, tanggalKembali: Tanggal;
		end;
		Kembali = record
			username: string;
			id: integer;
			tanggal: Tanggal;
		end;
		Laporan = record
			username: string;
			id: integer;
			tanggal: Tanggal;
		end;
		DataUser = record
			arr: array [1..NMAX] of User;
			length: integer;
		end;
		DataBuku = record
			arr: array [1..NMAX] of Buku;
			length: integer;
		end;
		DataPinjam = record
			arr: array [1..NMAX] of Pinjam;
			length: integer;
		end;
		DataKembali = record
			arr: array [1..NMAX] of Kembali;
			length: integer;
		end;
		DataLaporan = record
			arr: array [1..NMAX] of Laporan;
			length: integer;
		end;

	var
		userData: DataUser;
		bukuData: DataBuku;
		pinjamData: DataPinjam;
		kembaliData: DataKembali;
		laporanData: DataLaporan;
		validKategori: array [1..5] of string = ('sastra', 'sains', 'manga', 'sejarah', 'programming');
		userNul: User;
		bukuNul: Buku;

	procedure addBuku(o: Buku);
	procedure addUser(o: User);
	procedure addPinjam(o: Pinjam);
	procedure addKembali(o: Kembali);
	procedure addLaporan(o: Laporan);
	function isUserNull(u: User): boolean;
	function isBukuNull(b: Buku): boolean;
	function isPinjamNull(p: Pinjam): boolean;
	procedure addBukuCount(id, cnt: integer);
	procedure setPinjamStatus(username: string; id: integer; b: boolean);

implementation
	procedure addBuku(o: Buku);
		begin
			bukuData.length += 1;
			bukuData.arr[bukuData.length] := o;
		end;
	procedure addUser(o: User);
		begin
			userData.length += 1;
			userData.arr[userData.length] := o;
		end;
	procedure addPinjam(o: Pinjam);
		begin
			pinjamData.length += 1;
			pinjamData.arr[pinjamData.length] := o;
		end;
	procedure addKembali(o: Kembali);
		begin
			kembaliData.length += 1;
			kembaliData.arr[kembaliData.length] := o;
		end;
	procedure addLaporan(o: Laporan);
		begin
			laporanData.length += 1;
			laporanData.arr[laporanData.length] := o;
		end;
	function isUserNull(u: User): boolean;
		begin
			isUserNull := (u.nama = '') and (u.alamat = '') and (u.username = '') and (u.role = '') and (u.password = 0);
		end;
	function isBukuNull(b: Buku): boolean;
		begin
			isBukuNull := (b.id = 0) and (b.jumlah = 0) and (b.tahun = 0) and (b.judul = '') and (b.author = '') and (b.kategori = '');
		end;
	function isPinjamNull(p: Pinjam): boolean;
		begin
			isPinjamNull := (p.username = '') and (p.id = 0);
		end;
	procedure addBukuCount(id, cnt: integer);
		var
			i: integer;
		begin
			for i := 1 to bukuData.length do
				if (bukuData.arr[i].id = id) then begin
					bukuData.arr[i].jumlah += cnt;
					break;
				end;
		end;
	procedure setPinjamStatus(username: string; id: integer; b: boolean);
		var
			i: integer;
		begin
			for i := 1 to pinjamData.length do
				if (pinjamData.arr[i].username = username) and (pinjamData.arr[i].id = id) then begin
					pinjamData.arr[i].status := b;
					break;
				end;
		end;
end.