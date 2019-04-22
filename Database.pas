unit Database;

interface
	const
		NMAX = 1000; // Digunakan untuk menentukan maximal array data di program ini
		ROLE_PENGUNJUNG = 'Pengunjung'; // String default untuk role pengunjung
		ROLE_ADMIN = 'Admin'; // String default untuk role admin

	type
		// Type tanggal untuk menyimpan data tanggal (hari, bulan, dan tahun)
		Tanggal = record
			d, m, y: integer;
		end;
		// Type user untuk menyimpan data pengunjung
		User = record
			nama, alamat, username, role: string;
			password: int64;
		end;
		// Type buku untuk menyimpan data buku
		Buku = record
			id, jumlah, tahun: integer;
			judul, author, kategori: string;
		end;
		// Type pinjam untuk menyimpan data peminjaman buku
		Pinjam = record
			username: string;
			id: integer;
			status: boolean;
			tanggalPinjam, tanggalKembali: Tanggal;
		end;
		// Type kembali untuk menyimpan data pengembalian buku
		Kembali = record
			username: string;
			id: integer;
			tanggal: Tanggal;
		end;
		// Type laporan untuk menyimpan data laporan kehilangan buku
		Laporan = record
			username: string;
			id: integer;
			tanggal: Tanggal;
		end;
		// Type DataUser untuk menyimpan data-data bertipe user ke dalam array
		DataUser = record
			arr: array [1..NMAX] of User;
			length: integer;
		end;
		// Type DataBuku untuk menyimpan data-data bertipe buku ke dalam array
		DataBuku = record
			arr: array [1..NMAX] of Buku;
			length: integer;
		end;
		// Type DataPinjam untuk menyimpan data-data bertipe pinjam ke dalam array
		DataPinjam = record
			arr: array [1..NMAX] of Pinjam;
			length: integer;
		end;
		// Type DataKembali untuk menyimpan data-data bertipe kembali ke dalam array
		DataKembali = record
			arr: array [1..NMAX] of Kembali;
			length: integer;
		end;
		// Type DataLaporan untuk menyimpan data-data bertipe laporan ke dalam array
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
		// Array validKategori berisi string-string kategori yang terdaftar
		validKategori: array [1..5] of string = ('sastra', 'sains', 'manga', 'sejarah', 'programming');
		// Variabel user kosongan
		userNul: User;
		// Variabel buku kosongan
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
	// Menambahkan satu variabel Buku ke dalam databuku array
	procedure addBuku(o: Buku);
		begin
			bukuData.length += 1;
			bukuData.arr[bukuData.length] := o;
		end;

	// Menambahkan satu variabel User ke dalam datauser array
	procedure addUser(o: User);
		begin
			userData.length += 1;
			userData.arr[userData.length] := o;
		end;

	// Menambahkan satu variabel Pinjam ke dalam datapinjam array
	procedure addPinjam(o: Pinjam);
		begin
			pinjamData.length += 1;
			pinjamData.arr[pinjamData.length] := o;
		end;

	// Menambahkan satu variabel Kembali ke dalam datakembali array
	procedure addKembali(o: Kembali);
		begin
			kembaliData.length += 1;
			kembaliData.arr[kembaliData.length] := o;
		end;

	// Menambahkan satu variabel Laporan ke dalam datalaporan array
	procedure addLaporan(o: Laporan);
		begin
			laporanData.length += 1;
			laporanData.arr[laporanData.length] := o;
		end;

	// Mengecek apakah user u merupakan variabel kosongan
	function isUserNull(u: User): boolean;
		begin
			isUserNull := (u.nama = '') and (u.alamat = '') and (u.username = '') and (u.role = '') and (u.password = 0);
		end;

	// Mengecek apakah buku b merupakan variabel kosongan
	function isBukuNull(b: Buku): boolean;
		begin
			isBukuNull := (b.id = 0) and (b.jumlah = 0) and (b.tahun = 0) and (b.judul = '') and (b.author = '') and (b.kategori = '');
		end;

	// Mengecek apakah pinjam p merupakan variabel kosongan
	function isPinjamNull(p: Pinjam): boolean;
		begin
			isPinjamNull := (p.username = '') and (p.id = 0);
		end;

	// Menambahkan jumlah buku dengan id buku tertentu
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

	// Mengubah status peminjaman apabila sudah dikembalikan bukunya
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