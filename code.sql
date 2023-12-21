-- Buat tabel member
CREATE TABLE member (
  id_member SERIAL PRIMARY KEY,
  nama VARCHAR(255),
  alamat VARCHAR(255),
  no_telp VARCHAR(15),
  upline_id INT
);



-- Buat tabel downline
create table downline (
  id_member int,
  downline_id int
);

-- Membuat data dummy pada table member
INSERT INTO member (nama, alamat, no_telp, upline_id)
VALUES
  ('Andi', 'Jakarta', '081234567890', null),
  ('Budi', 'Medan', '081234567891', 1),
  ('Cici', 'Surabaya', '081234567892', 1),
  ('Didi', 'Bandung', '081234567893', 2),
  ('Eka', 'Yogyakarta', '081234567894', null),
  ('Fina', 'Bali', '081234567895', 1),
  ('Gina', 'Makassar', '081234567896', null),
  ('Heru', 'Semarang', '081234567897', null),
  ('Ira', 'Palembang', '081234567898', 2),
  ('Joni', 'Manado', '081234567899', 1);




-- Membuat data dummy pada table downline
INSERT INTO downline (id_member, downline_id)
VALUES
  (1, 2),
  (1, 3),
  (2, 4),
  (5, 6),
  (5, 7);

-- Membuat fungsi berdasarkan id
  CREATE OR REPLACE FUNCTION search_member_by_id(member_id INT)
RETURNS TABLE(MemberID INT, Nama VARCHAR(255), Alamat VARCHAR(255), NomorTelepon VARCHAR(15), UplineID INT, DownlineID INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT M.id_member AS MemberID, M.nama AS Nama, M.alamat AS Alamat, M.no_telp AS NomorTelepon, M.upline_id AS UplineID, D.downline_id AS DownlineID
    FROM member M
    LEFT JOIN downline D ON M.id_member = D.id_member
    WHERE M.id_member = member_id;
END;
$$ LANGUAGE plpgsql;

-- Contoh implementasi  mencari berdasarkan id
SELECT * FROM search_member_by_id(3);


-- Membuat fungsi berdasarkan name
    CREATE OR REPLACE FUNCTION search_member_by_name(search_name VARCHAR(255))
RETURNS TABLE(MemberID INT, Nama VARCHAR(255), Alamat VARCHAR(255), NomorTelepon VARCHAR(15), UplineID INT, DownlineID INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT M.id_member AS MemberID, M.nama AS Nama, M.alamat AS Alamat, M.no_telp AS NomorTelepon, M.upline_id AS UplineID, D.downline_id AS DownlineID
    FROM member M
    LEFT JOIN downline D ON M.id_member = D.id_member
    WHERE M.nama ILIKE '%' || search_name || '%';
END;
$$ LANGUAGE plpgsql;

-- Contoh implementasi  mencari berdasarkan id
SELECT * FROM search_member_by_name('Joni');


-- Membuat fungsi berdasarkan nomor telepon
CREATE OR REPLACE FUNCTION search_member_by_phone(search_phone VARCHAR(15))
RETURNS TABLE(MemberID INT, Nama VARCHAR(255), Alamat VARCHAR(255), NomorTelepon VARCHAR(15), UplineID INT, DownlineID INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT M.id_member AS MemberID, M.nama AS Nama, M.alamat AS Alamat, M.no_telp AS NomorTelepon, M.upline_id AS UplineID, D.downline_id AS DownlineID
    FROM member M
    LEFT JOIN downline D ON M.id_member = D.id_member
    WHERE M.no_telp = search_phone;
END;
$$ LANGUAGE plpgsql;

-- Contoh implementasi  mencari berdasarkan nomor telepon
SELECT * FROM search_member_by_phone('081234567896');


-- Membuat fungsi menampilkan semua member
CREATE OR REPLACE FUNCTION show_all_members()
RETURNS TABLE(MemberID INT, Nama VARCHAR(255), Alamat VARCHAR(255), NomorTelepon VARCHAR(15), UplineID INT, DownlineID INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT M.id_member AS MemberID, M.nama AS Nama, M.alamat AS Alamat, M.no_telp AS NomorTelepon, M.upline_id AS UplineID, D.downline_id AS DownlineID
    FROM member M
    LEFT JOIN downline D ON M.id_member = D.id_member;
END;
$$ LANGUAGE plpgsql;

-- Contoh implementasi menampilkan semua member
SELECT * FROM show_all_members();


-- Membuat fungsi dengan batasan downline 2 saja
CREATE OR REPLACE FUNCTION add_member_with_downline_limit(upline_name VARCHAR(255), upline_address VARCHAR(255), upline_phone VARCHAR(15), member_name VARCHAR(255), member_address VARCHAR(255), member_phone VARCHAR(15))
RETURNS VOID AS
$$
DECLARE
    upline_id INT;
    downline_count INT;
BEGIN
    -- Mencari ID upline berdasarkan nama, alamat, dan nomor telepon
    SELECT id_member INTO upline_id
    FROM member
    WHERE nama = upline_name AND alamat = upline_address AND no_telp = upline_phone;

    -- Menghitung jumlah downline dari upline
    SELECT COUNT(*) INTO downline_count
    FROM downline
    WHERE id_member = upline_id;

    -- Menambahkan anggota baru jika upline belum memiliki 2 downline
    IF downline_count < 2 THEN
        -- Tambahkan anggota baru dengan upline yang memenuhi syarat
        INSERT INTO member (nama, alamat, no_telp, upline_id)
        VALUES (member_name, member_address, member_phone, upline_id);
    ELSE
        -- Jika upline sudah memiliki 2 downline, pilih anggota lain yang belum memiliki 2 downline
        INSERT INTO member (nama, alamat, no_telp, upline_id)
        VALUES (member_name, member_address, member_phone,
            (SELECT id_member FROM member WHERE upline_id = upline_id AND
            (SELECT COUNT(*) FROM downline WHERE id_member = upline_id) < 2
            LIMIT 1)
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

