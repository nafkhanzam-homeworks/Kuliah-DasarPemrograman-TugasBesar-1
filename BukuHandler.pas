unit BukuHandler;

interface
	uses
		Util, Database, UserHandler;

	procedure kembalikan_buku; 
	procedure cari;
	procedure pinjam_buku;
	procedure tambah_buku;
	procedure tambah_jumlah_buku;
	procedure riwayat;
	procedure caritahunterbit;
	procedure lapor_hilang;
	procedure lihat_laporan;
	procedure statistik;

implementation
	// Prosedur writeBukuNotFound memberitahu pengguna bahwa id buku tidak ada
	procedure writeBukuNotFound(id: integer);
		begin
			writeln('Buku dengan ID: ', id, ' tidak ditemukan');
		end;

	// Prosedur kembalikan_buku digunakan untuk mengembalikan buku
	procedure kembalikan_buku;
		var
			k: Kembali;
			b: Buku;
			p: Pinjam;
			s: string;
			i: integer;
		begin
			b := bukuNul;
			k.username := loggedUser.username;
			write('Masukkan id buku yang dikembalikan: ');
			readln(k.id);
			b := findBuku(k.id);
			if isBukuNull(b) then
				writeBukuNotFound(k.id)
			else begin
				p := findPinjam(k.id, k.username);
				if isPinjamNull(p) then
					writeln(k.username, ' tidak pernah meminjam buku tersebut!')
				else begin
					writeln('Data peminjaman:');
					writeln('Username: ', k.username);
					writeln('Judul buku: ', b.judul);
					writeln('Tanggal peminjaman: ', tanggalToString(p.tanggalPinjam));
					writeln('Tanggal batas pengembalian: ', tanggalToString(p.tanggalKembali));
					writeln;
					write('Masukkan tanggal hari ini: ');
					readln(s);
					k.tanggal := getTanggal(s);
					i := hitungHari(p.tanggalKembali, k.tanggal);
					if (i > 0) then begin
						writeln('Anda terlambat mengembalikan buku.');
						writeln('Anda terkena denda ', 2000*i, '.');
					end else begin
						writeln('Terima kasih sudah meminjam.');
					end;
					addKembali(k);
					setPinjamStatus(p.username, p.id, true);
					addBukuCount(p.id, 1);
				end;
			end;
		end;

	// Prosedur cari digunakan untuk mencari buku berdasarkan kategori
	procedure cari;
		var
			i: integer;
			s: string;
			b: Buku;
			res: DataBuku;
		begin
			write('Masukkan kategori: ');
			readln(s);
			while not(isKategoriValid(s)) do begin
				writeln('Kategori ', s, ' tidak valid');
				writeln('Kategori: ', getKategoriString);
				write('Masukkan kategori: ');
				readln(s);
			end;
			res.length := 0;
			for i := 1 to bukuData.length do begin
				b := bukuData.arr[i];
				if (b.kategori = s) then begin
					res.length += 1;
					res.arr[res.length] := b;
				end;
			end;
			writeln;
			if res.length > 0 then begin
				sortBukuData(res);
				writeln('Hasil pencarian:');
				for i := 1 to res.length do begin
					b := res.arr[i];
					writeln(b.id, ' | ', b.judul, ' | ', b.author);
				end;
			end else
				writeln('Tidak ada buku dalam kategori ini.')
		end;

	// Prosedur pinjam_buku digunakan untuk meminjam buku
	procedure pinjam_buku;
		var
			p: Pinjam;
			b: Buku;
			s: string;
		begin
			b := bukuNul;
			write('Masukkan id buku yang ingin dipinjam: ');
			readln(p.id);
			b := findBuku(p.id);
			if isBukuNull(b) then
				writeBukuNotFound(p.id)
			else begin
				write('Masukkan tanggal hari ini: ');
				readln(s);
				if (b.jumlah > 0) then begin
					p.tanggalPinjam := getTanggal(s);
					p.tanggalKembali := get1WeekAfter(p.tanggalPinjam);
					addBukuCount(p.id, -1);
					writeln('Buku ', b.judul, ' berhasil dipinjam!');
					writeln('Tersisa ', b.jumlah-1, ' buku ', b.judul, '.');
					writeln('Terima kasih sudah meminjam.');
					p.status := false;
					p.username := loggedUser.username;
					addPinjam(p);
				end else begin
					writeln('Buku ', b.judul, ' sedang habis!');
					writeln('Coba lain kali');
				end;
			end;
		end;

	// Prosedur tambah_buku digunakan untuk menambah buku baru ke sistem
	procedure tambah_buku;
		var
			b: Buku;
		begin
			writeln('Masukkan Informasi buku yang ditambahkan:');
			write('Masukkan id buku: ');
			readln(b.id);
			write('Masukkan judul buku: ');
			readln(b.judul);
			write('Masukkan pengarang buku: ');
			readln(b.author);
			write('Masukkan jumlah buku: ');
			readln(b.jumlah);
			write('Masukkan tahun terbit buku: ');
			readln(b.tahun);
			write('Masukkan kategori buku: ');
			readln(b.kategori);
			while not(isKategoriValid(b.kategori)) do begin
				writeln('Kategori ', b.kategori, ' tidak valid');
				writeln('Kategori: ', getKategoriString);
				write('Masukkan kategori buku: ');
				readln(b.kategori);
			end;
			addBuku(b);
			writeln;
			writeln('Buku berhasil ditambahkan ke dalam sistem!');
		end;

	// Prosedur tambah_jumlah_buku digunakan untuk menambahkan jumlah buku ke sistem
	procedure tambah_jumlah_buku;
		var
			i: integer;
			b: Buku;
		begin
			b := bukuNul;
			write('Masukkan ID Buku: ');
			readln(i);
			b := findBuku(i);
			if isBukuNull(b) then
				writeBukuNotFound(i)
			else begin
				write('Masukkan jumlah buku yang ditambahkan: ');
				readln(i);
				addBukuCount(b.id, i);
				writeln('Pembaharuan jumlah buku berhasil dilakukan, total buku ', b.judul, ' di perpustakaan menjadi ', b.jumlah+i, '.');
			end;
		end;

	// Prosedur riwayat digunakan untuk menampilkan riwayat peminjaman buku
	procedure riwayat;
		var
			i: integer;
			s: string;
			k: Kembali;
		begin
			write('Masukkan username pengunjung: ');
			readln(s);
			writeln('Riwayat:');
			for i := 1 to pinjamData.length do begin
				k := kembaliData.arr[i];
				if (k.username = s) then
					writeln(tanggalToString(k.tanggal), ' | ', k.id, ' | ', findBuku(k.id).judul);
			end;
		end;

	// Prosedur caritahunterbit digunakan untuk mencari buku berdasarkan tahun terbit dengan kategori tertentu
	procedure caritahunterbit;
		var
			thn, cnt, i: integer;
			kat: string;
			b: Buku;
		begin
			write('Masukkan tahun: ');
			readln(thn);
			write('Masukkan kategori: ');
			readln(kat);
			writeln('Buku yang terbit ', kat, ' ', thn, ':');
			for i := 1 to bukuData.length do begin
				b := bukuData.arr[i];
				if ((kat = '=') and (b.tahun = thn)) or ((kat = '<') and (b.tahun < thn)) or
					 ((kat = '<=') and (b.tahun <= thn)) or ((kat = '>') and (b.tahun > thn)) or
					 ((kat = '>=') and (b.tahun >= thn)) then begin
					writeln(b.id, ' | ', b.judul, ' | ', b.author);
					cnt += 1;
				end;
			end;
			if (cnt = 0) then
				writeln('Tidak ada buku dalam kategori ini.');
		end;

	// Prosedur lapor_hilang digunakan untuk melaporkan buku yang hilang
	procedure lapor_hilang;
		var
			l: Laporan;
			s: string;
		begin
			write('Masukkan id buku : ');
			readln(l.id);
			if isBukuNull(findBuku(l.id)) then
				writeBukuNotFound(l.id)
			else begin
				write('Masukkan judul buku : ');
				readln(s); // temporary dummy
				write('Masukkan tanggal pelaporan : ');
				readln(s);
				l.tanggal := getTanggal(s);
				l.username := loggedUser.username;
				writeln('');
				writeln('Laporan berhasil diterima.');
				addLaporan(l);
			end;
		end;

	// Prosedur lihat_laporan digunakan untuk melihat laporan buku yang hilang
	procedure lihat_laporan;
		var
			l: Laporan;
			i: integer;
		begin
			writeln('Buku yang hilang :');
			for i := 1 to laporanData.length do begin
				l := laporanData.arr[i];
				writeln(l.id, ' | ', findBuku(l.id).judul, ' | ', tanggalToString(l.tanggal));
			end;
		end;

	// Prosedur statistik digunakan untuk melihat statistik yang berkaitan dengan pengguna dan buku
	procedure statistik;
		var
			adminCnt, pengunjungCnt, tot, i: integer;
			u: User;
			b: Buku;
			cntArr: array [1..length(validKategori)] of integer;
		begin
			adminCnt := 0;
			pengunjungCnt := 0;
			for i := 1 to length(validKategori) do
				cntArr[i] := 0;
			writeln('Pengguna:');
			for i := 1 to userData.length do begin
				u := userData.arr[i];
				if u.role = 'Admin' then
					adminCnt += 1
				else if u.role = 'Pengunjung' then
					pengunjungCnt += 1;
			end;
			writeln('Admin | ', adminCnt);
			writeln('Pengunjung | ', pengunjungCnt);
			writeln('Total | ', adminCnt + pengunjungCnt);
			writeln;
			writeln('Buku:');
			for i := 1 to bukuData.length do
				cntArr[getKategoriID(bukuData.arr[i].kategori)] += 1;
			tot := 0;
			for i := 1 to length(validKategori) do begin
				writeln(validKategori[i], ' | ', cntArr[i]);
				tot += cntArr[i];
			end;
			writeln('Total | ', tot);
		end;
end.