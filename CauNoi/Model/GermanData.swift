import Foundation

struct GWord: Identifiable {
    let de: String            // ohne Artikel
    let art: String?          // "der"/"die"/"das", nil = kein Nomen
    let pl: String?           // Pluralform ohne Artikel
    let vi: String
    let cat: String           // Kategorie auf Vietnamesisch
    let note: String          // Hinweis auf Vietnamesisch

    var id: String { de }
    var full: String { art.map { "\($0) \(de)" } ?? de }
}

struct GPhrase: Identifiable {
    let de: String; let vi: String; let cat: String
    var id: String { de }
}

enum GermanData {

    static let coreWords: [GWord] = [
        // Sức khỏe
        GWord(de: "Termin", art: "der", pl: "Termine", vi: "cuộc hẹn", cat: "Sức khỏe", note: "quan trọng nhất nước Đức — đi đâu cũng cần hẹn trước"),
        GWord(de: "Arzt", art: "der", pl: "Ärzte", vi: "bác sĩ", cat: "Sức khỏe", note: "bác sĩ nữ: die Ärztin"),
        GWord(de: "Krankenhaus", art: "das", pl: "Krankenhäuser", vi: "bệnh viện", cat: "Sức khỏe", note: ""),
        GWord(de: "Apotheke", art: "die", pl: "Apotheken", vi: "hiệu thuốc", cat: "Sức khỏe", note: ""),
        GWord(de: "Rezept", art: "das", pl: "Rezepte", vi: "đơn thuốc", cat: "Sức khỏe", note: "cũng có nghĩa: công thức nấu ăn"),
        GWord(de: "Krankenkasse", art: "die", pl: "Krankenkassen", vi: "bảo hiểm y tế", cat: "Sức khỏe", note: ""),
        GWord(de: "Schmerz", art: "der", pl: "Schmerzen", vi: "cơn đau", cat: "Sức khỏe", note: "thường dùng số nhiều: Schmerzen"),
        GWord(de: "Erkältung", art: "die", pl: "Erkältungen", vi: "cảm lạnh", cat: "Sức khỏe", note: ""),
        GWord(de: "Fieber", art: "das", pl: nil, vi: "sốt", cat: "Sức khỏe", note: ""),
        GWord(de: "Tablette", art: "die", pl: "Tabletten", vi: "viên thuốc", cat: "Sức khỏe", note: ""),
        GWord(de: "krank", art: nil, pl: nil, vi: "ốm, bệnh", cat: "Sức khỏe", note: ""),
        GWord(de: "gesund", art: nil, pl: nil, vi: "khỏe mạnh", cat: "Sức khỏe", note: ""),
        GWord(de: "müde", art: nil, pl: nil, vi: "mệt", cat: "Sức khỏe", note: ""),
        // Giấy tờ
        GWord(de: "Ausweis", art: "der", pl: "Ausweise", vi: "giấy tờ tùy thân", cat: "Giấy tờ", note: ""),
        GWord(de: "Reisepass", art: "der", pl: "Reisepässe", vi: "hộ chiếu", cat: "Giấy tờ", note: ""),
        GWord(de: "Anmeldung", art: "die", pl: "Anmeldungen", vi: "đăng ký (cư trú)", cat: "Giấy tờ", note: ""),
        GWord(de: "Formular", art: "das", pl: "Formulare", vi: "mẫu đơn", cat: "Giấy tờ", note: ""),
        GWord(de: "Unterschrift", art: "die", pl: "Unterschriften", vi: "chữ ký", cat: "Giấy tờ", note: ""),
        GWord(de: "Amt", art: "das", pl: "Ämter", vi: "cơ quan hành chính", cat: "Giấy tờ", note: ""),
        GWord(de: "Antrag", art: "der", pl: "Anträge", vi: "đơn xin", cat: "Giấy tờ", note: ""),
        GWord(de: "Frist", art: "die", pl: "Fristen", vi: "thời hạn", cat: "Giấy tờ", note: "trễ hạn ở Đức là chuyện lớn"),
        GWord(de: "Brief", art: "der", pl: "Briefe", vi: "lá thư", cat: "Giấy tờ", note: ""),
        GWord(de: "Rechnung", art: "die", pl: "Rechnungen", vi: "hóa đơn", cat: "Giấy tờ", note: ""),
        GWord(de: "Vertrag", art: "der", pl: "Verträge", vi: "hợp đồng", cat: "Giấy tờ", note: ""),
        GWord(de: "Steuer", art: "die", pl: "Steuern", vi: "thuế", cat: "Giấy tờ", note: ""),
        // Nhà cửa
        GWord(de: "Wohnung", art: "die", pl: "Wohnungen", vi: "căn hộ", cat: "Nhà cửa", note: ""),
        GWord(de: "Miete", art: "die", pl: "Mieten", vi: "tiền thuê nhà", cat: "Nhà cửa", note: ""),
        GWord(de: "Vermieter", art: "der", pl: "Vermieter", vi: "chủ nhà", cat: "Nhà cửa", note: ""),
        GWord(de: "Schlüssel", art: "der", pl: "Schlüssel", vi: "chìa khóa", cat: "Nhà cửa", note: ""),
        GWord(de: "Nachbar", art: "der", pl: "Nachbarn", vi: "hàng xóm", cat: "Nhà cửa", note: ""),
        GWord(de: "Küche", art: "die", pl: "Küchen", vi: "nhà bếp", cat: "Nhà cửa", note: ""),
        GWord(de: "Fenster", art: "das", pl: "Fenster", vi: "cửa sổ", cat: "Nhà cửa", note: ""),
        GWord(de: "Heizung", art: "die", pl: "Heizungen", vi: "lò sưởi", cat: "Nhà cửa", note: ""),
        GWord(de: "Mülltonne", art: "die", pl: "Mülltonnen", vi: "thùng rác", cat: "Nhà cửa", note: "Đức phân loại rác rất kỹ"),
        // Mua sắm
        GWord(de: "Geld", art: "das", pl: nil, vi: "tiền", cat: "Mua sắm", note: ""),
        GWord(de: "Preis", art: "der", pl: "Preise", vi: "giá", cat: "Mua sắm", note: ""),
        GWord(de: "Angebot", art: "das", pl: "Angebote", vi: "hàng giảm giá", cat: "Mua sắm", note: ""),
        GWord(de: "Kasse", art: "die", pl: "Kassen", vi: "quầy thu ngân", cat: "Mua sắm", note: ""),
        GWord(de: "Tüte", art: "die", pl: "Tüten", vi: "cái túi", cat: "Mua sắm", note: ""),
        GWord(de: "Brot", art: "das", pl: "Brote", vi: "bánh mì", cat: "Mua sắm", note: ""),
        GWord(de: "Gemüse", art: "das", pl: nil, vi: "rau củ", cat: "Mua sắm", note: ""),
        GWord(de: "Obst", art: "das", pl: nil, vi: "trái cây", cat: "Mua sắm", note: ""),
        GWord(de: "Fleisch", art: "das", pl: nil, vi: "thịt", cat: "Mua sắm", note: ""),
        GWord(de: "Fisch", art: "der", pl: "Fische", vi: "cá", cat: "Mua sắm", note: ""),
        GWord(de: "Reis", art: "der", pl: nil, vi: "gạo, cơm", cat: "Mua sắm", note: ""),
        GWord(de: "Milch", art: "die", pl: nil, vi: "sữa", cat: "Mua sắm", note: ""),
        GWord(de: "Ei", art: "das", pl: "Eier", vi: "quả trứng", cat: "Mua sắm", note: ""),
        GWord(de: "Zucker", art: "der", pl: nil, vi: "đường", cat: "Mua sắm", note: ""),
        GWord(de: "Salz", art: "das", pl: nil, vi: "muối", cat: "Mua sắm", note: ""),
        GWord(de: "Wasser", art: "das", pl: nil, vi: "nước", cat: "Mua sắm", note: ""),
        GWord(de: "teuer", art: nil, pl: nil, vi: "đắt", cat: "Mua sắm", note: ""),
        GWord(de: "billig", art: nil, pl: nil, vi: "rẻ", cat: "Mua sắm", note: ""),
        // Đi lại
        GWord(de: "Bahnhof", art: "der", pl: "Bahnhöfe", vi: "nhà ga", cat: "Đi lại", note: ""),
        GWord(de: "Zug", art: "der", pl: "Züge", vi: "tàu hỏa", cat: "Đi lại", note: ""),
        GWord(de: "Bus", art: "der", pl: "Busse", vi: "xe buýt", cat: "Đi lại", note: ""),
        GWord(de: "Haltestelle", art: "die", pl: "Haltestellen", vi: "trạm dừng", cat: "Đi lại", note: ""),
        GWord(de: "Fahrrad", art: "das", pl: "Fahrräder", vi: "xe đạp", cat: "Đi lại", note: ""),
        GWord(de: "Führerschein", art: "der", pl: "Führerscheine", vi: "bằng lái xe", cat: "Đi lại", note: ""),
        GWord(de: "Straße", art: "die", pl: "Straßen", vi: "con đường", cat: "Đi lại", note: ""),
        GWord(de: "Fahrkarte", art: "die", pl: "Fahrkarten", vi: "vé xe", cat: "Đi lại", note: ""),
        // Công việc
        GWord(de: "Arbeit", art: "die", pl: "Arbeiten", vi: "công việc", cat: "Công việc", note: ""),
        GWord(de: "Chef", art: "der", pl: "Chefs", vi: "sếp", cat: "Công việc", note: ""),
        GWord(de: "Kollege", art: "der", pl: "Kollegen", vi: "đồng nghiệp", cat: "Công việc", note: ""),
        GWord(de: "Urlaub", art: "der", pl: "Urlaube", vi: "kỳ nghỉ phép", cat: "Công việc", note: ""),
        GWord(de: "Pause", art: "die", pl: "Pausen", vi: "giờ giải lao", cat: "Công việc", note: ""),
        GWord(de: "Schicht", art: "die", pl: "Schichten", vi: "ca làm", cat: "Công việc", note: ""),
        GWord(de: "Lohn", art: "der", pl: "Löhne", vi: "tiền lương", cat: "Công việc", note: ""),
        GWord(de: "Feierabend", art: "der", pl: "Feierabende", vi: "giờ tan làm", cat: "Công việc", note: "「Schönen Feierabend!」 = câu chào đồng nghiệp lúc về"),
        // Thời gian
        GWord(de: "Woche", art: "die", pl: "Wochen", vi: "tuần", cat: "Thời gian", note: ""),
        GWord(de: "Monat", art: "der", pl: "Monate", vi: "tháng", cat: "Thời gian", note: ""),
        GWord(de: "Jahr", art: "das", pl: "Jahre", vi: "năm", cat: "Thời gian", note: ""),
        GWord(de: "Uhr", art: "die", pl: "Uhren", vi: "đồng hồ, giờ", cat: "Thời gian", note: "8 Uhr = 8 giờ"),
        GWord(de: "Wochenende", art: "das", pl: "Wochenenden", vi: "cuối tuần", cat: "Thời gian", note: ""),
        GWord(de: "heute", art: nil, pl: nil, vi: "hôm nay", cat: "Thời gian", note: ""),
        GWord(de: "morgen", art: nil, pl: nil, vi: "ngày mai", cat: "Thời gian", note: "viết hoa der Morgen = buổi sáng"),
        GWord(de: "gestern", art: nil, pl: nil, vi: "hôm qua", cat: "Thời gian", note: ""),
        GWord(de: "pünktlich", art: nil, pl: nil, vi: "đúng giờ", cat: "Thời gian", note: "người Đức coi trọng lắm"),
        GWord(de: "Verspätung", art: "die", pl: "Verspätungen", vi: "sự trễ giờ", cat: "Thời gian", note: ""),
        // Gia đình & giao tiếp
        GWord(de: "Familie", art: "die", pl: "Familien", vi: "gia đình", cat: "Gia đình", note: ""),
        GWord(de: "Eltern", art: "die", pl: nil, vi: "bố mẹ", cat: "Gia đình", note: "luôn là số nhiều"),
        GWord(de: "Kind", art: "das", pl: "Kinder", vi: "đứa con, đứa trẻ", cat: "Gia đình", note: ""),
        GWord(de: "Sohn", art: "der", pl: "Söhne", vi: "con trai", cat: "Gia đình", note: ""),
        GWord(de: "Tochter", art: "die", pl: "Töchter", vi: "con gái", cat: "Gia đình", note: ""),
        GWord(de: "Enkelkind", art: "das", pl: "Enkelkinder", vi: "cháu", cat: "Gia đình", note: ""),
        GWord(de: "Freund", art: "der", pl: "Freunde", vi: "người bạn", cat: "Gia đình", note: ""),
        GWord(de: "Hilfe", art: "die", pl: "Hilfen", vi: "sự giúp đỡ", cat: "Gia đình", note: ""),
        GWord(de: "Frage", art: "die", pl: "Fragen", vi: "câu hỏi", cat: "Gia đình", note: ""),
        GWord(de: "Antwort", art: "die", pl: "Antworten", vi: "câu trả lời", cat: "Gia đình", note: ""),
        GWord(de: "Sprache", art: "die", pl: "Sprachen", vi: "ngôn ngữ", cat: "Gia đình", note: ""),
        GWord(de: "Wort", art: "das", pl: "Wörter", vi: "từ", cat: "Gia đình", note: ""),
        // Động từ & tính từ
        GWord(de: "verstehen", art: nil, pl: nil, vi: "hiểu", cat: "Động từ", note: ""),
        GWord(de: "sprechen", art: nil, pl: nil, vi: "nói", cat: "Động từ", note: ""),
        GWord(de: "wiederholen", art: nil, pl: nil, vi: "nhắc lại", cat: "Động từ", note: ""),
        GWord(de: "helfen", art: nil, pl: nil, vi: "giúp", cat: "Động từ", note: ""),
        GWord(de: "warten", art: nil, pl: nil, vi: "đợi", cat: "Động từ", note: ""),
        GWord(de: "bezahlen", art: nil, pl: nil, vi: "trả tiền", cat: "Động từ", note: ""),
        GWord(de: "brauchen", art: nil, pl: nil, vi: "cần", cat: "Động từ", note: ""),
        GWord(de: "suchen", art: nil, pl: nil, vi: "tìm", cat: "Động từ", note: ""),
        GWord(de: "finden", art: nil, pl: nil, vi: "tìm thấy", cat: "Động từ", note: ""),
        GWord(de: "anrufen", art: nil, pl: nil, vi: "gọi điện", cat: "Động từ", note: ""),
        GWord(de: "langsam", art: nil, pl: nil, vi: "chậm", cat: "Động từ", note: ""),
        GWord(de: "schnell", art: nil, pl: nil, vi: "nhanh", cat: "Động từ", note: ""),
        GWord(de: "schwer", art: nil, pl: nil, vi: "khó, nặng", cat: "Động từ", note: ""),
        GWord(de: "leicht", art: nil, pl: nil, vi: "dễ, nhẹ", cat: "Động từ", note: "")
    ]

    /// Nur Nomen — für das Artikel-Quiz.
    static let nouns: [GWord] = words.filter { $0.art != nil }

    static let corePhrases: [GPhrase] = [
        GPhrase(de: "Guten Morgen!", vi: "Chào buổi sáng!", cat: "Chào hỏi"),
        GPhrase(de: "Guten Tag!", vi: "Xin chào! (ban ngày)", cat: "Chào hỏi"),
        GPhrase(de: "Auf Wiedersehen!", vi: "Tạm biệt!", cat: "Chào hỏi"),
        GPhrase(de: "Wie geht es Ihnen?", vi: "Ông/bà có khỏe không?", cat: "Chào hỏi"),
        GPhrase(de: "Danke, gut.", vi: "Cảm ơn, tôi khỏe.", cat: "Chào hỏi"),
        GPhrase(de: "Entschuldigung!", vi: "Xin lỗi!", cat: "Chào hỏi"),
        GPhrase(de: "Vielen Dank für Ihre Hilfe!", vi: "Cảm ơn nhiều vì đã giúp đỡ!", cat: "Chào hỏi"),
        GPhrase(de: "Schönes Wochenende!", vi: "Chúc cuối tuần vui vẻ!", cat: "Chào hỏi"),

        GPhrase(de: "Ich verstehe nicht.", vi: "Tôi không hiểu.", cat: "Khi chưa hiểu"),
        GPhrase(de: "Bitte sprechen Sie langsam.", vi: "Xin nói chậm thôi.", cat: "Khi chưa hiểu"),
        GPhrase(de: "Können Sie das wiederholen?", vi: "Ông/bà nhắc lại được không?", cat: "Khi chưa hiểu"),
        GPhrase(de: "Was bedeutet das?", vi: "Cái này nghĩa là gì?", cat: "Khi chưa hiểu"),
        GPhrase(de: "Ich spreche nur wenig Deutsch.", vi: "Tôi chỉ nói được ít tiếng Đức.", cat: "Khi chưa hiểu"),
        GPhrase(de: "Mein Kind kann übersetzen.", vi: "Con tôi có thể phiên dịch.", cat: "Khi chưa hiểu"),
        GPhrase(de: "Bitte schreiben Sie es auf.", vi: "Xin viết ra giấy giúp tôi.", cat: "Khi chưa hiểu"),

        GPhrase(de: "Ich habe einen Termin.", vi: "Tôi có hẹn.", cat: "Ở phòng khám"),
        GPhrase(de: "Ich möchte einen Termin machen.", vi: "Tôi muốn đặt lịch hẹn.", cat: "Ở phòng khám"),
        GPhrase(de: "Ich habe Schmerzen.", vi: "Tôi bị đau.", cat: "Ở phòng khám"),
        GPhrase(de: "Hier tut es weh.", vi: "Đau ở chỗ này.", cat: "Ở phòng khám"),
        GPhrase(de: "Wo tut es weh?", vi: "Đau ở đâu? (bác sĩ hỏi)", cat: "Ở phòng khám"),
        GPhrase(de: "Hier ist meine Versichertenkarte.", vi: "Đây là thẻ bảo hiểm của tôi.", cat: "Ở phòng khám"),
        GPhrase(de: "Ich brauche ein Rezept.", vi: "Tôi cần đơn thuốc.", cat: "Ở phòng khám"),

        GPhrase(de: "Ich möchte das anmelden.", vi: "Tôi muốn đăng ký cái này.", cat: "Ở cơ quan"),
        GPhrase(de: "Welche Unterlagen brauche ich?", vi: "Tôi cần những giấy tờ gì?", cat: "Ở cơ quan"),
        GPhrase(de: "Bitte hier unterschreiben.", vi: "Xin ký vào đây. (nhân viên nói)", cat: "Ở cơ quan"),
        GPhrase(de: "Ich habe einen Brief bekommen.", vi: "Tôi nhận được một lá thư.", cat: "Ở cơ quan"),

        GPhrase(de: "Was kostet das?", vi: "Cái này giá bao nhiêu?", cat: "Mua sắm"),
        GPhrase(de: "Das ist zu teuer.", vi: "Đắt quá.", cat: "Mua sắm"),
        GPhrase(de: "Ich hätte gern ein Brot.", vi: "Cho tôi một ổ bánh mì.", cat: "Mua sắm"),
        GPhrase(de: "Mit Karte, bitte.", vi: "Tôi trả bằng thẻ.", cat: "Mua sắm"),
        GPhrase(de: "Haben Sie eine Tüte?", vi: "Có túi không ạ?", cat: "Mua sắm"),

        GPhrase(de: "Guten Tag, ich bin Ihre Nachbarin.", vi: "Chào, tôi là hàng xóm của ông/bà. (nữ)", cat: "Hàng xóm"),
        GPhrase(de: "Können Sie mir bitte helfen?", vi: "Ông/bà giúp tôi được không?", cat: "Hàng xóm"),
        GPhrase(de: "Bis morgen!", vi: "Hẹn ngày mai!", cat: "Hàng xóm")
    ]

    static let phraseCats: [String] = ["Chào hỏi", "Khi chưa hiểu", "Ở phòng khám", "Ở cơ quan", "Mua sắm", "Hàng xóm", "Ở nhà hàng", "Hỏi đường", "Gọi điện", "Thời tiết & chuyện phiếm", "Gia đình & cảm xúc"]

    /// Deutsche Laute, erklärt auf Vietnamesisch.
    static let sounds: [SoundCard] = [
        SoundCard(head: "w", desc: "Đọc như chữ „v“ tiếng Việt.", warn: "", examples: [("Wasser","nước"),("wie","như thế nào"),("wo","ở đâu")]),
        SoundCard(head: "v", desc: "Thường đọc như „ph“ tiếng Việt (f).", warn: "Ngược với chữ w — dễ nhầm!", examples: [("Vater","bố"),("viel","nhiều"),("verstehen","hiểu")]),
        SoundCard(head: "s + nguyên âm", desc: "Đầu từ, trước nguyên âm: đọc như „d“ miền Bắc (dơ).", warn: "", examples: [("sagen","nói"),("Sohn","con trai"),("Suppe","súp")]),
        SoundCard(head: "ß · ss", desc: "Đọc như „x“ tiếng Việt.", warn: "", examples: [("Straße","con đường"),("essen","ăn")]),
        SoundCard(head: "sch", desc: "Đọc như „s“ miền Nam (sờ nặng).", warn: "", examples: [("schnell","nhanh"),("Schule","trường học"),("Tisch","cái bàn")]),
        SoundCard(head: "st- · sp-", desc: "Đầu từ đọc là „scht“, „schp“.", warn: "Straße đọc là „Schtraße“.", examples: [("Straße","con đường"),("sprechen","nói"),("Stadt","thành phố")]),
        SoundCard(head: "ch sau a, o, u", desc: "Đọc như „kh“ tiếng Việt.", warn: "", examples: [("machen","làm"),("Buch","quyển sách"),("auch","cũng")]),
        SoundCard(head: "ch sau i, e", desc: "Nhẹ hơn — như tiếng gió khi nói „hy“.", warn: "", examples: [("ich","tôi"),("nicht","không"),("möchte","muốn")]),
        SoundCard(head: "z", desc: "Đọc là „t“ + „x“ dính liền: „tx“.", warn: "Không bao giờ đọc như „d“.", examples: [("zahlen","trả tiền"),("Zug","tàu hỏa"),("Zucker","đường")]),
        SoundCard(head: "ei", desc: "Đọc là „ai“.", warn: "nein đọc là „nain“.", examples: [("nein","không"),("mein","của tôi"),("Arbeit","công việc")]),
        SoundCard(head: "ie", desc: "Đọc là „i“ kéo dài.", warn: "Ngược với ei!", examples: [("wie","như thế nào"),("viel","nhiều"),("Liebe","tình yêu")]),
        SoundCard(head: "eu · äu", desc: "Đọc là „oi“.", warn: "", examples: [("heute","hôm nay"),("teuer","đắt"),("Häuser","những căn nhà")]),
        SoundCard(head: "ö", desc: "Nói „ê“ nhưng chu môi tròn như „ô“.", warn: "Gần giống „ơ“ tiếng Việt nhưng tròn môi.", examples: [("schön","đẹp"),("möchte","muốn"),("hören","nghe")]),
        SoundCard(head: "ü", desc: "Nói „i“ nhưng chu môi tròn như „u“.", warn: "", examples: [("über","về, trên"),("müde","mệt"),("Tüte","cái túi")]),
        SoundCard(head: "ä", desc: "Đọc như „e“ tiếng Việt.", warn: "", examples: [("spät","muộn"),("Ärzte","các bác sĩ")]),
        SoundCard(head: "h sau nguyên âm", desc: "Không đọc — chỉ làm nguyên âm dài ra.", warn: "", examples: [("wohnen","ở, cư trú"),("Uhr","đồng hồ"),("zehn","mười")]),
        SoundCard(head: "-er cuối từ", desc: "Đọc gần như „a“ nhẹ.", warn: "Wasser nghe như „Vassa“.", examples: [("Wasser","nước"),("Vater","bố"),("teuer","đắt")]),
        SoundCard(head: "b, d, g cuối từ", desc: "Đọc cứng thành p, t, k.", warn: "Tag nghe như „Tak“.", examples: [("halb","một nửa"),("Kind","đứa trẻ"),("Tag","ngày")]),
        SoundCard(head: "Không có thanh điệu", desc: "Tiếng Đức không có dấu — chỉ có trọng âm. Nói đều giọng, nhấn mạnh một âm tiết.", warn: "Đừng „hát“ như tiếng Việt.", examples: [("verstehen","hiểu — nhấn âm giữa: ver-STE-hen"),("Arbeit","công việc — nhấn âm đầu: AR-beit")])
    ]

    /// Zahlen mit der Umkehr-Warnung.
    static let numberNote = "Số tiếng Đức đọc ngược từ 21 trở đi: einundzwanzig = „một-và-hai-mươi“ = 21. Nghe số điện thoại phải cẩn thận!"
    static let numbers: [(String, String)] = [
        ("eins","1"),("zwei","2"),("drei","3"),("vier","4"),("fünf","5"),
        ("sechs","6"),("sieben","7"),("acht","8"),("neun","9"),("zehn","10"),
        ("elf","11"),("zwölf","12"),("zwanzig","20"),("einundzwanzig","21 ⚠️"),
        ("dreißig","30"),("hundert","100"),("tausend","1000")
    ]
}

// ── Grammatik: Artikel-Faustregeln & Beispielsätze ──────
extension GermanData {

    struct ArticleRule {
        let suffix: String
        let art: String
        let vi: String       // Regel auf Vietnamesisch
        let sure: Bool       // true = (fast) ausnahmslos
    }

    static let articleRules: [ArticleRule] = [
        ArticleRule(suffix: "ung",    art: "die", vi: "đuôi -ung → luôn là die",            sure: true),
        ArticleRule(suffix: "heit",   art: "die", vi: "đuôi -heit → luôn là die",           sure: true),
        ArticleRule(suffix: "keit",   art: "die", vi: "đuôi -keit → luôn là die",           sure: true),
        ArticleRule(suffix: "schaft", art: "die", vi: "đuôi -schaft → luôn là die",         sure: true),
        ArticleRule(suffix: "ion",    art: "die", vi: "đuôi -ion → luôn là die",            sure: true),
        ArticleRule(suffix: "tät",    art: "die", vi: "đuôi -tät → luôn là die",            sure: true),
        ArticleRule(suffix: "chen",   art: "das", vi: "đuôi -chen → luôn là das",           sure: true),
        ArticleRule(suffix: "lein",   art: "das", vi: "đuôi -lein → luôn là das",           sure: true),
        ArticleRule(suffix: "e",      art: "die", vi: "đuôi -e → thường là die (khoảng 90%)", sure: false),
        ArticleRule(suffix: "er",     art: "der", vi: "đuôi -er → thường là der",           sure: false)
    ]

    /// Faustregel-Hinweis für ein Nomen — erkennt auch Ausnahmen.
    static func articleHint(de: String, art: String) -> String? {
        for r in articleRules where de.hasSuffix(r.suffix) {
            if art == r.art {
                return "Mẹo: \(r.vi)."
            }
            if r.sure { return nil }   // sichere Regel + Widerspruch: Regel greift hier nicht, nichts behaupten
            return "Chú ý: \(r.vi) — nhưng từ này là ngoại lệ: \(art) \(de)!"
        }
        return nil
    }

    /// Kurze Alltagssätze zu den wichtigsten Nomen: de-Wort → (Satz, Übersetzung).
    static let examples: [String: (de: String, vi: String)] = [
        "Termin":        ("Ich habe morgen einen Termin.", "Ngày mai tôi có hẹn."),
        "Arzt":          ("Der Arzt kommt gleich.", "Bác sĩ sắp đến."),
        "Krankenhaus":   ("Sie liegt im Krankenhaus.", "Bà ấy đang nằm viện."),
        "Apotheke":      ("Die Apotheke ist um die Ecke.", "Hiệu thuốc ở ngay góc phố."),
        "Rezept":        ("Hier ist Ihr Rezept.", "Đây là đơn thuốc của ông/bà."),
        "Krankenkasse":  ("Die Krankenkasse bezahlt das.", "Bảo hiểm y tế trả tiền cái này."),
        "Schmerz":       ("Die Schmerzen sind weg.", "Cơn đau đã hết."),
        "Tablette":      ("Nehmen Sie die Tablette nach dem Essen.", "Uống thuốc sau khi ăn."),
        "Fieber":        ("Das Kind hat Fieber.", "Đứa bé bị sốt."),
        "Ausweis":       ("Ihren Ausweis, bitte.", "Xin cho xem giấy tờ."),
        "Reisepass":     ("Mein Reisepass ist abgelaufen.", "Hộ chiếu của tôi hết hạn rồi."),
        "Formular":      ("Bitte füllen Sie das Formular aus.", "Xin điền vào mẫu đơn."),
        "Unterschrift":  ("Ihre Unterschrift fehlt noch.", "Còn thiếu chữ ký của ông/bà."),
        "Amt":           ("Ich muss heute zum Amt.", "Hôm nay tôi phải lên cơ quan."),
        "Antrag":        ("Der Antrag ist genehmigt.", "Đơn đã được duyệt."),
        "Frist":         ("Die Frist endet am Freitag.", "Thời hạn đến thứ Sáu."),
        "Brief":         ("Da ist ein Brief für dich.", "Có thư cho con này."),
        "Rechnung":      ("Die Rechnung ist schon bezahlt.", "Hóa đơn trả rồi."),
        "Vertrag":       ("Lesen Sie den Vertrag genau.", "Đọc kỹ hợp đồng."),
        "Wohnung":       ("Die Wohnung ist im dritten Stock.", "Căn hộ ở tầng ba."),
        "Miete":         ("Die Miete ist teuer geworden.", "Tiền nhà đắt lên rồi."),
        "Schlüssel":     ("Wo ist der Schlüssel?", "Chìa khóa đâu rồi?"),
        "Nachbar":       ("Der Nachbar ist sehr nett.", "Hàng xóm rất tốt bụng."),
        "Geld":          ("Ich habe kein Geld dabei.", "Tôi không mang tiền theo."),
        "Kasse":         ("Bitte an der Kasse zahlen.", "Xin trả tiền ở quầy."),
        "Brot":          ("Das Brot ist noch warm.", "Bánh mì còn nóng."),
        "Zug":           ("Der Zug hat Verspätung.", "Tàu bị trễ."),
        "Bus":           ("Der Bus kommt alle zehn Minuten.", "Mười phút có một chuyến xe buýt."),
        "Haltestelle":   ("Die Haltestelle ist gegenüber.", "Trạm dừng ở bên kia đường."),
        "Fahrkarte":     ("Eine Fahrkarte nach Berlin, bitte.", "Cho một vé đi Berlin."),
        "Arbeit":        ("Die Arbeit beginnt um sechs.", "Công việc bắt đầu lúc sáu giờ."),
        "Urlaub":        ("Wir haben nächste Woche Urlaub.", "Tuần sau chúng tôi nghỉ phép."),
        "Pause":         ("Machen wir eine Pause.", "Mình nghỉ giải lao chút."),
        "Uhr":           ("Es ist schon acht Uhr.", "Đã tám giờ rồi."),
        "Woche":         ("Bis nächste Woche!", "Hẹn tuần sau!"),
        "Familie":       ("Die ganze Familie kommt.", "Cả nhà cùng đến."),
        "Kind":          ("Das Kind schläft schon.", "Đứa bé ngủ rồi."),
        "Tochter":       ("Meine Tochter spricht gut Deutsch.", "Con gái tôi nói tiếng Đức giỏi."),
        "Sohn":          ("Mein Sohn wohnt in Berlin.", "Con trai tôi sống ở Berlin."),
        "Hilfe":         ("Danke für die Hilfe!", "Cảm ơn vì đã giúp!"),
        "Frage":         ("Ich habe eine Frage.", "Tôi có một câu hỏi."),
        "Sprache":       ("Deutsch ist eine schwere Sprache.", "Tiếng Đức là một ngôn ngữ khó."),
        "Wort":          ("Dieses Wort kenne ich nicht.", "Từ này tôi không biết.")
    ]
}
