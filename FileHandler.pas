// Unit FileHandler digunakan untuk menjalankan
// command yang berhubungan dengan file management
unit FileHandler;

interface
	uses
		Util, Database;
	const
		// Header data file csv buku
		BUKU_HEADER = 'ID_Buku,Judul_Buku,Author,Jumlah_Buku,Tahun_Penerbit,Kategori';
		// Header data file csv pengguna
		USER_HEADER = 'Nama,Alamat,Username,Password,Role';
		// Header data file csv peminjaman buku
		PINJAM_HEADER = 'Username,ID_Buku,Tanggal_Peminjaman,Tanggal_Batas_Pengembalian,Status_Pengembalian';
		// Header data file csv pengembalian buku
		KEMBALI_HEADER = 'Username,ID_Buku,Tanggal_Pengembalian';
		// Header data file csv laporan kehilangan
		LAPORAN_HEADER = 'Username,ID_Buku_Hilang,Tanggal_Laporan';

	type
		// Type array berisi string dari index 1 sampai NMAX
		StringArray = array [1..NMAX] of string;
		// Type array berisi StringArray dari index 1 sampai NMAX
		Table = record
			arr: array [1..NMAX] of StringArray;
			row, col: integer;
		end;

	var
		namaFileBuku, namaFileUser, namaFilePinjam, namaFileKembali, namaFileLaporan: string;
		fileBuku, fileUser, filePinjam, fileKembali, fileLaporan: TextFile;
		u: User;
		b: Buku;
		p: Pinjam;
		k: Kembali;
		h: Laporan;
		t: Table;
	procedure save;
	procedure load;

implementation
	// Prosedur inputFiles digunakan untuk mengassign
	// semua TextFile untuk dibaca/ditulis
	procedure inputFiles;
		begin
			write('Masukkan nama File Buku: ');
			readln(namaFileBuku);
			// namaFileBuku := 'buku.csv';
			assign(fileBuku, namaFileBuku);

			write('Masukkan nama File User: ');
			readln(namaFileUser);
			// namaFileUser := 'user.csv';
			assign(fileUser, namaFileUser);
			
			write('Masukkan nama File Peminjaman: ');
			readln(namaFilePinjam);
			// namaFilePinjam := 'pinjam.csv';
			assign(filePinjam, namaFilePinjam);
			
			write('Masukkan nama File Pengembalian: ');
			readln(namaFileKembali);
			// namaFileKembali := 'kembali.csv';
			assign(fileKembali, namaFileKembali);
			
			write('Masukkan nama File Buku Laporan: ');
			readln(namaFileLaporan);
			// namaFileLaporan := 'laporan.csv';
			assign(fileLaporan, namaFileLaporan);
		end;

	// Prosedur save digunakan untuk melakukan penyimpanan data
	procedure save;
		var
			i: integer;
		begin
			inputFiles;

			rewrite(fileBuku);
			writeln(fileBuku, BUKU_HEADER);
			for i := 1 to bukuData.length do begin
				b := bukuData.arr[i];
				writeln(fileBuku, b.id, ',', toCSV(b.judul), ',', toCSV(b.author), ',', b.jumlah, ',', b.tahun, ',', toCSV(b.kategori));
			end;
			close(fileBuku);

			rewrite(fileUser);
			writeln(fileUser, USER_HEADER);
			for i := 1 to userData.length do begin
				u := userData.arr[i];
				writeln(fileUser, toCSV(u.nama), ',', toCSV(u.alamat), ',', toCSV(u.username), ',', u.password, ',', toCSV(u.role));
			end;
			close(fileUser);

			rewrite(filePinjam);
			writeln(filePinjam, PINJAM_HEADER);
			for i := 1 to pinjamData.length do begin
				p := pinjamData.arr[i];
				writeln(filePinjam, toCSV(p.username), ',', p.id, ',', tanggalToString(p.tanggalPinjam), ',', tanggalToString(p.tanggalKembali), ',', p.status);
			end;
			close(filePinjam);

			rewrite(fileKembali);
			writeln(fileKembali, KEMBALI_HEADER);
			for i := 1 to kembaliData.length do begin
				k := kembaliData.arr[i];
				writeln(fileKembali, toCSV(k.username), ',', k.id, ',', tanggalToString(k.tanggal));
			end;
			close(fileKembali);

			rewrite(fileLaporan);
			writeln(fileLaporan, LAPORAN_HEADER);
			for i := 1 to laporanData.length do begin
				h := laporanData.arr[i];
				writeln(fileLaporan, toCSV(h.username), ',', h.id, ',', tanggalToString(h.tanggal));
			end;
			close(fileLaporan);

			writeln('Data berhasil disimpan!');
		end;

	// Prosedur addRow digunakan untuk menambahkan string ke dalam row baru
	procedure addRow(s: string);
		var
			col: integer;
			c: char;
			inside: boolean;
		begin
			t.row += 1;
			for col := 1 to t.col do
				t.arr[t.row][col] := '';
			col := 1;
			for c in s do
				if (c = ',') and not inside then
					col += 1
				else if (c = '"') then
					inside := not inside
				else
					t.arr[t.row][col] += c;
		end;

	// Prosedur readData membaca TextFile dengan format csv
	// dengan kolom tertentu kedalam table t
	procedure readData(var f: TextFile; col: integer);
		var
			line: string;
			i, j: integer;
		begin
			t.col := col;
			t.row := 0;
			reset(f);
			if not eof(f) then
				readln(f, line);
			while not eof(f) do begin
				readln(f, line);
				addRow(line);
			end;
			close(f);
			for i := 1 to t.row do
				for j := 1 to t.col do
					t.arr[i][j] := fromCSV(t.arr[i][j]);
		end;

	// Prosedur load digunakan untuk load data
	procedure load;
		var
			i: integer;
		begin
			inputFiles;

			readData(fileBuku, columnCount(BUKU_HEADER));
			bukuData.length := 0;
			for i := 1 to t.row do begin
				b.id := parseInt(t.arr[i][1]);
				b.judul := t.arr[i][2];
				b.author := t.arr[i][3];
				b.jumlah := parseInt(t.arr[i][4]);
				b.tahun := parseInt(t.arr[i][5]);
				b.kategori := t.arr[i][6];
				addBuku(b);
			end;

			readData(fileUser, columnCount(USER_HEADER));
			userData.length := 0;
			for i := 1 to t.row do begin
				u.nama := t.arr[i][1];
				u.alamat := t.arr[i][2];
				u.username := t.arr[i][3];
				u.password := parseInt(t.arr[i][4]);
				u.role := t.arr[i][5];
				addUser(u);
			end;

			readData(filePinjam, columnCount(PINJAM_HEADER));
			pinjamData.length := 0;
			for i := 1 to t.row do begin
				p.username := t.arr[i][1];
				p.id := parseInt(t.arr[i][2]);
				p.tanggalPinjam := getTanggal(t.arr[i][3]);
				p.tanggalKembali := getTanggal(t.arr[i][4]);
				p.status := t.arr[i][5] = 'TRUE';
				addPinjam(p);
			end;

			readData(fileKembali, columnCount(KEMBALI_HEADER));
			kembaliData.length := 0;
			for i := 1 to t.row do begin
				k.username := t.arr[i][1];
				k.id := parseInt(t.arr[i][2]);
				k.tanggal := getTanggal(t.arr[i][3]);
				addKembali(k);
			end;

			readData(fileLaporan, columnCount(LAPORAN_HEADER));
			laporanData.length := 0;
			for i := 1 to t.row do begin
				h.username := t.arr[i][1];
				h.id := parseInt(t.arr[i][2]);
				h.tanggal := getTanggal(t.arr[i][3]);
				addLaporan(h);
			end;

			writeln('File perpustakaan berhasil dimuat!');
		end;

end.