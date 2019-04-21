program MainProgram;

uses 
	Database, Util, UserHandler, FileHandler, BukuHandler;

var
	running: boolean;
	role: integer; // 0 guest, 1 user, 2 admin
	cmd: string;
	adminCmds: array [1..7] of string = ('register', 'lihat_laporan', 'tambah_buku', 'tambah_jumlah_buku', 'riwayat', 'statistik', 'cari_anggota');
	userCmds: array [1..5] of string = ('caritahunterbit', 'pinjam_buku', 'kembalikan_buku', 'lapor_hilang', 'logout');
procedure init;
	begin
		userData.length := 0;
		bukuData.length := 0;
		pinjamData.length := 0;
		kembaliData.length := 0;
		laporanData.length := 0;
		role := 0;
		running := true;
	end;
procedure updateRole;
	begin
		if loggedUser.role = ROLE_ADMIN then
			role := 2
		else if loggedUser.role = ROLE_PENGUNJUNG then
			role := 1
		else
			role := 0;
	end;
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
procedure logout;
	begin
		loggedUser := userNul;
		writeln('Logout berhasil!');
	end;
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
procedure help;
	begin
		writeln('this is help');
	end;

begin
	init;
	load;
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