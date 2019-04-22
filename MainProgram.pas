// Program utama perpustakaan
program MainProgram;

// Menggunakan berbagai macam unit buatan sendiri untuk menjalankan program ini
uses 
	Database, Util, UserHandler, FileHandler, BukuHandler;

// Kamus
var
	// untuk menentukan kalau program masih berjalan (true) atau pengguna ingin keluar (false)
	running: boolean;
	// Status si pengguna (0: tamu | 1: pengunjung | 2: admin)
	role: integer;
	// String input command dari pengguna
	cmd: string;
	// Array yang berisi string command yang hanya bisa digunakan oleh admin
	adminCmds: array [1..7] of string = ('register', 'lihat_laporan', 'tambah_buku', 'tambah_jumlah_buku', 'riwayat', 'statistik', 'cari_anggota');
	// Array yang berisi string command yang hanya bisa digunakan oleh pengunjung
	userCmds: array [1..5] of string = ('caritahunterbit', 'pinjam_buku', 'kembalikan_buku', 'lapor_hilang', 'logout');

// Digunakan untuk mengupdate role pengguna
procedure updateRole;
	begin
		if loggedUser.role = ROLE_ADMIN then
			role := 2
		else if loggedUser.role = ROLE_PENGUNJUNG then
			role := 1
		else
			role := 0;
	end;

// Mengecek input command dari pengguna, apakah diperbolehkan atau tidak
function checkCmd: boolean;
	var
		s: string;
	begin
		checkCmd := true;
		if (role < 2) then
			for s in adminCmds do
				if (s = cmd) then begin
					checkCmd := false;
					writeln('Command tersebut hanya untuk admin!');
					break;
				end;
		if (role < 1) then
			for s in userCmds do begin
				if (s = cmd) then begin
					checkCmd := false;
					writeln('Anda harus login terlebih dahulu!');
					break;
				end;
			end;
	end;

// Digunakan untuk logout dari akun
procedure logout;
	begin
		if (isUserNull(loggedUser)) then
			writeln('Anda belum login!')
		else begin
			loggedUser := userNul;
			writeln('Logout berhasil!');
		end;
	end;

// Digunakan untuk keluar dari program dengan mengkonfirmasi apakah pengguna ingin menyimpan file dahulu
procedure exit;
	begin
		write('Apakah anda mau melakukan penyimpanan file yang sudah dilakukan (Y/N) ? ');
		readln(cmd);
		if (cmd = 'Y') or (cmd = 'N') then begin
			if (cmd = 'Y') then
				save;
			running := false;
		end;
	end;

// Digunakan untuk menunjukkan petunjuk serta command-command yang tersedia dalam program perpustakaan
procedure help;
	begin
		writeln(' ');
		writeln('Untuk memilih fitur dalam program ini, pengguna hanya perlu memasukkan salah satu input di bawah ini: ');
		writeln(' ');
		writeln('--- MENU HANYA UNTUK ADMIN ---');
		writeln('register : Menu untuk mendaftarkan user pertama kali (hanya boleh dilakukan oleh admin)');
		writeln('lihat_laporan : Menu untuk melihat laporan buku yang hilang.');
		writeln('tambah_buku : Menu untuk menambah buku baru ke sistem.');
		writeln('tambah_jumlah_buku : Menu untuk menambahkan jumlah buku ke sistem.');
		writeln('riwayat : Menu untuk menampilkan riwayat peminjaman buku.');
		writeln('statistik : Menu untuk melihat statistik yang berkaitan dengan pengguna dan buku.');
		writeln('cari_anggota : Menu untuk mencari data diri dari anggota perpustakaan.');
		writeln(' ');
		writeln('--- MENU UMUM---');
		writeln('login : Menu untuk mengakses program dengan memasukkan identitas dari user pengguna dan kata sandi guna mendapatkan hak akses.');
		writeln('cari : Menu untuk mencari buku berdasarkan kategori (kategori hanya ada 5, yaitu sastra, sains, manga, sejarah, dan programming).');
		writeln('caritahunterbit : Menu untuk mencari buku berdasarkan tahun terbit (Pengguna program akan diminta untuk memasukkan input tahun dan keterangan simbol).');
		writeln('pinjam_buku : Menu untuk meminjam buku (Hanya bisa dilakukan setelah login).');
		writeln('kembalikan _buku : Menu untuk mengembalikan buku (Hanya bisa dilakukan setelah login).');
		writeln('lapor_hilang : Menu untuk melaporkan buku yang hilang.');
		writeln('load : Menu untuk load data.');
		writeln('save : Menu untuk melakukan penyimpanan data.');
		writeln('exit : Menu untuk keluar dari program.');
	end;

// Algoritma program utama
begin
	running := true;
	writeln('Selamat datang di Program Perpustakaan!');
	writeln('Silakan load data terlebih dahulu.');
	load;
	writeln('Silakan langsung input fitur yang akan dipakai.');
	writeln('(Jika bingung, tulis "help")');
	while running do begin
		updateRole;
		readln(cmd);
		if (checkCmd) then
			case cmd of
				'register': register;
				'login': login;
				'cari': cari;
				'caritahunterbit': caritahunterbit;
				'pinjam_buku': pinjam_buku;
				'kembalikan_buku': kembalikan_buku;
				'lapor_hilang': lapor_hilang;
				'tambah_buku': tambah_buku;
				'tambah_jumlah_buku': tambah_jumlah_buku;
				'riwayat': riwayat;
				'statistik': statistik;
				'load': load;
				'save': save;
				'cari_anggota': cari_anggota;
				'help': help;
				'exit': exit;
				'logout': logout;
			else
				writeln('Command ', cmd, ' tidak ada! ketik "help" untuk bantuan.');
			end;
	end;
	writeln('Keluar dari program...');
end.