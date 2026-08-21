import Foundation

struct VWord: Identifiable {
    let v: String; let de: String; let cat: String; let note: String
    var id: String { v }
}
struct VSentence: Identifiable {
    let vi: String; let de: String
    var id: String { vi }
}
struct SoundCard: Identifiable {
    let head: String; let desc: String; let warn: String
    let examples: [(String, String)]
    var id: String { head }
}

enum VietnameseData {

    static let coreWords: [VWord] = [
        // Familie
        VWord(v: "bố", de: "Vater", cat: "Familie", note: "im Norden; im Süden: ba"),
        VWord(v: "mẹ", de: "Mutter", cat: "Familie", note: "im Norden; im Süden: má"),
        VWord(v: "ông", de: "Großvater", cat: "Familie", note: "ông nội = väterlich, ông ngoại = mütterlich"),
        VWord(v: "bà", de: "Großmutter", cat: "Familie", note: ""),
        VWord(v: "anh", de: "älterer Bruder", cat: "Familie", note: "auch Anrede für ältere Männer"),
        VWord(v: "chị", de: "ältere Schwester", cat: "Familie", note: ""),
        VWord(v: "em", de: "jüngeres Geschwister", cat: "Familie", note: "auch: ich, gegenüber Älteren"),
        VWord(v: "con", de: "Kind", cat: "Familie", note: "auch: ich, gegenüber den Eltern"),
        VWord(v: "cháu", de: "Enkelkind, Nichte, Neffe", cat: "Familie", note: ""),
        VWord(v: "cô", de: "Tante (Schwester des Vaters)", cat: "Familie", note: "auch: Lehrerin"),
        VWord(v: "chú", de: "Onkel (jüngerer Bruder des Vaters)", cat: "Familie", note: ""),
        VWord(v: "bác", de: "älterer Onkel oder ältere Tante", cat: "Familie", note: ""),
        VWord(v: "dì", de: "Tante (Schwester der Mutter)", cat: "Familie", note: ""),
        VWord(v: "cậu", de: "Onkel (Bruder der Mutter)", cat: "Familie", note: ""),
        VWord(v: "vợ", de: "Ehefrau", cat: "Familie", note: ""),
        VWord(v: "chồng", de: "Ehemann", cat: "Familie", note: ""),
        VWord(v: "bạn", de: "Freund, Freundin", cat: "Familie", note: ""),
        VWord(v: "gia đình", de: "Familie", cat: "Familie", note: ""),
        VWord(v: "họ hàng", de: "Verwandtschaft", cat: "Familie", note: ""),
        // Essen
        VWord(v: "cơm", de: "gekochter Reis, Mahlzeit", cat: "Essen", note: ""),
        VWord(v: "phở", de: "Phở, Nudelsuppe", cat: "Essen", note: ""),
        VWord(v: "bún", de: "Reisnudeln", cat: "Essen", note: ""),
        VWord(v: "mì", de: "Weizennudeln", cat: "Essen", note: ""),
        VWord(v: "bánh", de: "Kuchen, Gebäck, Teigware", cat: "Essen", note: ""),
        VWord(v: "nước", de: "Wasser", cat: "Essen", note: "heißt auch: Land"),
        VWord(v: "mắm", de: "fermentierte Fischsauce", cat: "Essen", note: ""),
        VWord(v: "thịt", de: "Fleisch", cat: "Essen", note: ""),
        VWord(v: "cá", de: "Fisch", cat: "Essen", note: ""),
        VWord(v: "gà", de: "Huhn", cat: "Essen", note: ""),
        VWord(v: "rau", de: "Gemüse", cat: "Essen", note: ""),
        VWord(v: "trứng", de: "Ei", cat: "Essen", note: ""),
        VWord(v: "muối", de: "Salz", cat: "Essen", note: ""),
        VWord(v: "đường", de: "Zucker", cat: "Essen", note: "dasselbe Wort heißt auch: Straße"),
        VWord(v: "ớt", de: "Chili", cat: "Essen", note: ""),
        VWord(v: "trà", de: "Tee", cat: "Essen", note: ""),
        VWord(v: "cà phê", de: "Kaffee", cat: "Essen", note: ""),
        VWord(v: "chợ", de: "Markt", cat: "Essen", note: ""),
        VWord(v: "ăn", de: "essen", cat: "Essen", note: ""),
        VWord(v: "uống", de: "trinken", cat: "Essen", note: ""),
        VWord(v: "nấu", de: "kochen", cat: "Essen", note: ""),
        VWord(v: "ngon", de: "lecker", cat: "Essen", note: ""),
        VWord(v: "đói", de: "hungrig", cat: "Essen", note: ""),
        VWord(v: "no", de: "satt", cat: "Essen", note: ""),
        VWord(v: "khát", de: "durstig", cat: "Essen", note: ""),
        // Zuhause
        VWord(v: "nhà", de: "Haus, Zuhause", cat: "Zuhause", note: ""),
        VWord(v: "cửa", de: "Tür", cat: "Zuhause", note: ""),
        VWord(v: "bàn", de: "Tisch", cat: "Zuhause", note: ""),
        VWord(v: "ghế", de: "Stuhl", cat: "Zuhause", note: ""),
        VWord(v: "giường", de: "Bett", cat: "Zuhause", note: ""),
        VWord(v: "phòng", de: "Zimmer", cat: "Zuhause", note: ""),
        VWord(v: "bếp", de: "Küche", cat: "Zuhause", note: ""),
        VWord(v: "xe", de: "Fahrzeug", cat: "Zuhause", note: "xe đạp = Fahrrad, xe hơi = Auto"),
        VWord(v: "tiền", de: "Geld", cat: "Zuhause", note: ""),
        VWord(v: "sách", de: "Buch", cat: "Zuhause", note: ""),
        VWord(v: "chữ", de: "Schriftzeichen, Wort, Schrift", cat: "Zuhause", note: ""),
        VWord(v: "áo", de: "Oberbekleidung, Hemd", cat: "Zuhause", note: ""),
        VWord(v: "quần", de: "Hose", cat: "Zuhause", note: ""),
        VWord(v: "giày", de: "Schuh", cat: "Zuhause", note: ""),
        VWord(v: "đèn", de: "Lampe", cat: "Zuhause", note: ""),
        VWord(v: "điện thoại", de: "Telefon", cat: "Zuhause", note: ""),
        // Tun
        VWord(v: "đi", de: "gehen", cat: "Tun", note: ""),
        VWord(v: "về", de: "zurückgehen, heimkommen", cat: "Tun", note: ""),
        VWord(v: "đến", de: "ankommen, kommen zu", cat: "Tun", note: ""),
        VWord(v: "làm", de: "machen, arbeiten", cat: "Tun", note: ""),
        VWord(v: "nói", de: "sprechen, sagen", cat: "Tun", note: ""),
        VWord(v: "nghe", de: "hören", cat: "Tun", note: ""),
        VWord(v: "xem", de: "anschauen", cat: "Tun", note: ""),
        VWord(v: "đọc", de: "lesen", cat: "Tun", note: ""),
        VWord(v: "viết", de: "schreiben", cat: "Tun", note: ""),
        VWord(v: "học", de: "lernen", cat: "Tun", note: ""),
        VWord(v: "hỏi", de: "fragen", cat: "Tun", note: "genauso heißt der Haken-Ton"),
        VWord(v: "ngủ", de: "schlafen", cat: "Tun", note: ""),
        VWord(v: "dậy", de: "aufstehen, aufwachen", cat: "Tun", note: ""),
        VWord(v: "mua", de: "kaufen", cat: "Tun", note: ""),
        VWord(v: "bán", de: "verkaufen", cat: "Tun", note: ""),
        VWord(v: "yêu", de: "lieben", cat: "Tun", note: ""),
        VWord(v: "thương", de: "lieb haben, zugetan sein", cat: "Tun", note: "wärmer als yêu, sagt man in der Familie"),
        VWord(v: "thích", de: "mögen", cat: "Tun", note: ""),
        VWord(v: "biết", de: "wissen, können", cat: "Tun", note: ""),
        VWord(v: "hiểu", de: "verstehen", cat: "Tun", note: ""),
        VWord(v: "nhớ", de: "sich erinnern, vermissen", cat: "Tun", note: ""),
        VWord(v: "quên", de: "vergessen", cat: "Tun", note: ""),
        VWord(v: "cho", de: "geben, lassen", cat: "Tun", note: ""),
        VWord(v: "lấy", de: "nehmen, holen", cat: "Tun", note: ""),
        VWord(v: "đợi", de: "warten", cat: "Tun", note: ""),
        VWord(v: "giúp", de: "helfen", cat: "Tun", note: ""),
        VWord(v: "gọi", de: "rufen, anrufen, bestellen", cat: "Tun", note: ""),
        VWord(v: "ở", de: "wohnen, sich befinden, in", cat: "Tun", note: ""),
        VWord(v: "có", de: "haben, es gibt", cat: "Tun", note: ""),
        VWord(v: "muốn", de: "wollen", cat: "Tun", note: ""),
        VWord(v: "cần", de: "brauchen", cat: "Tun", note: ""),
        // Eigenschaft
        VWord(v: "lớn", de: "groß", cat: "Eigenschaft", note: ""),
        VWord(v: "nhỏ", de: "klein", cat: "Eigenschaft", note: ""),
        VWord(v: "đẹp", de: "schön", cat: "Eigenschaft", note: ""),
        VWord(v: "mới", de: "neu", cat: "Eigenschaft", note: ""),
        VWord(v: "cũ", de: "alt (Gegenstand)", cat: "Eigenschaft", note: ""),
        VWord(v: "già", de: "alt (Mensch)", cat: "Eigenschaft", note: ""),
        VWord(v: "trẻ", de: "jung", cat: "Eigenschaft", note: ""),
        VWord(v: "nhanh", de: "schnell", cat: "Eigenschaft", note: ""),
        VWord(v: "chậm", de: "langsam", cat: "Eigenschaft", note: ""),
        VWord(v: "nóng", de: "heiß", cat: "Eigenschaft", note: ""),
        VWord(v: "lạnh", de: "kalt", cat: "Eigenschaft", note: ""),
        VWord(v: "vui", de: "fröhlich", cat: "Eigenschaft", note: ""),
        VWord(v: "buồn", de: "traurig", cat: "Eigenschaft", note: ""),
        VWord(v: "mệt", de: "müde, erschöpft", cat: "Eigenschaft", note: ""),
        VWord(v: "khỏe", de: "gesund, fit", cat: "Eigenschaft", note: ""),
        VWord(v: "dễ", de: "leicht, einfach", cat: "Eigenschaft", note: ""),
        VWord(v: "khó", de: "schwierig", cat: "Eigenschaft", note: ""),
        VWord(v: "xa", de: "weit", cat: "Eigenschaft", note: ""),
        VWord(v: "gần", de: "nah", cat: "Eigenschaft", note: ""),
        VWord(v: "nhiều", de: "viel", cat: "Eigenschaft", note: ""),
        VWord(v: "ít", de: "wenig", cat: "Eigenschaft", note: ""),
        VWord(v: "giỏi", de: "gut in etwas, tüchtig", cat: "Eigenschaft", note: ""),
        // Zahl
        VWord(v: "một", de: "eins", cat: "Zahl", note: ""),
        VWord(v: "hai", de: "zwei", cat: "Zahl", note: ""),
        VWord(v: "ba", de: "drei", cat: "Zahl", note: "gleich geschrieben wie ba = Papa (Süden)"),
        VWord(v: "bốn", de: "vier", cat: "Zahl", note: ""),
        VWord(v: "năm", de: "fünf", cat: "Zahl", note: "heißt auch: Jahr"),
        VWord(v: "sáu", de: "sechs", cat: "Zahl", note: ""),
        VWord(v: "bảy", de: "sieben", cat: "Zahl", note: ""),
        VWord(v: "tám", de: "acht", cat: "Zahl", note: ""),
        VWord(v: "chín", de: "neun", cat: "Zahl", note: ""),
        VWord(v: "mười", de: "zehn", cat: "Zahl", note: ""),
        VWord(v: "trăm", de: "hundert", cat: "Zahl", note: ""),
        VWord(v: "nghìn", de: "tausend", cat: "Zahl", note: "im Süden: ngàn"),
        // Zeit
        VWord(v: "hôm nay", de: "heute", cat: "Zeit", note: ""),
        VWord(v: "hôm qua", de: "gestern", cat: "Zeit", note: ""),
        VWord(v: "ngày mai", de: "morgen", cat: "Zeit", note: ""),
        VWord(v: "bây giờ", de: "jetzt", cat: "Zeit", note: ""),
        VWord(v: "sáng", de: "Morgen, morgens", cat: "Zeit", note: ""),
        VWord(v: "trưa", de: "Mittag", cat: "Zeit", note: ""),
        VWord(v: "chiều", de: "Nachmittag", cat: "Zeit", note: ""),
        VWord(v: "tối", de: "Abend", cat: "Zeit", note: ""),
        VWord(v: "đêm", de: "Nacht", cat: "Zeit", note: ""),
        VWord(v: "ngày", de: "Tag", cat: "Zeit", note: ""),
        VWord(v: "tuần", de: "Woche", cat: "Zeit", note: ""),
        VWord(v: "tháng", de: "Monat", cat: "Zeit", note: ""),
        VWord(v: "giờ", de: "Stunde, Uhrzeit", cat: "Zeit", note: ""),
        VWord(v: "lâu", de: "lange (Zeit)", cat: "Zeit", note: ""),
        // Wendung
        VWord(v: "cảm ơn", de: "danke", cat: "Wendung", note: ""),
        VWord(v: "xin lỗi", de: "Entschuldigung", cat: "Wendung", note: ""),
        VWord(v: "không sao", de: "kein Problem", cat: "Wendung", note: ""),
        VWord(v: "tạm biệt", de: "auf Wiedersehen", cat: "Wendung", note: ""),
        VWord(v: "không", de: "nein, nicht", cat: "Wendung", note: ""),
        VWord(v: "vâng", de: "ja (höflich, Norden)", cat: "Wendung", note: "im Süden: dạ"),
        VWord(v: "tiếng Việt", de: "die vietnamesische Sprache", cat: "Wendung", note: ""),
        VWord(v: "người", de: "Mensch, Person", cat: "Wendung", note: ""),
        VWord(v: "Việt Nam", de: "Vietnam", cat: "Wendung", note: ""),
        VWord(v: "nước Đức", de: "Deutschland", cat: "Wendung", note: "")
    ]

    /// Einsilbige Wörter fürs Tonquiz.
    static let tonePool: [VWord] = words.filter { !$0.v.contains(" ") }

    static let coreSentences: [VSentence] = [
        VSentence(vi: "Con chào bố mẹ.", de: "Hallo Mama, hallo Papa."),
        VSentence(vi: "Ăn cơm chưa?", de: "Hast du schon gegessen? — die normalste Begrüßung überhaupt."),
        VSentence(vi: "Hôm nay con đi học.", de: "Heute gehe ich zur Schule."),
        VSentence(vi: "Mẹ ơi, con đói bụng rồi.", de: "Mama, ich hab Hunger."),
        VSentence(vi: "Cả nhà mình ăn cơm nhé.", de: "Lasst uns alle zusammen essen."),
        VSentence(vi: "Bà nấu phở ngon lắm.", de: "Oma kocht sehr leckere Phở."),
        VSentence(vi: "Con không hiểu chữ này.", de: "Dieses Wort verstehe ich nicht."),
        VSentence(vi: "Anh ấy nói tiếng Việt rất giỏi.", de: "Er spricht sehr gut Vietnamesisch."),
        VSentence(vi: "Em đang học viết tiếng Việt.", de: "Ich lerne gerade, Vietnamesisch zu schreiben."),
        VSentence(vi: "Bố mẹ con sinh ra ở Việt Nam.", de: "Meine Eltern sind in Vietnam geboren."),
        VSentence(vi: "Con sinh ra và lớn lên ở Đức.", de: "Ich bin in Deutschland geboren und aufgewachsen."),
        VSentence(vi: "Nhà mình có bốn người.", de: "Wir sind vier zu Hause."),
        VSentence(vi: "Chị đi làm về muộn.", de: "Meine große Schwester kommt spät von der Arbeit."),
        VSentence(vi: "Trời hôm nay lạnh quá.", de: "Heute ist es echt kalt."),
        VSentence(vi: "Con thương bố mẹ nhiều lắm.", de: "Ich hab euch sehr lieb."),
        VSentence(vi: "Cuối tuần mình về thăm ông bà.", de: "Am Wochenende besuchen wir Oma und Opa."),
        VSentence(vi: "Tiếng Việt có sáu thanh điệu.", de: "Vietnamesisch hat sechs Töne."),
        VSentence(vi: "Con tập đọc mỗi ngày một chút.", de: "Ich übe jeden Tag ein bisschen lesen."),
        VSentence(vi: "Xin lỗi, con quên mất rồi.", de: "Entschuldigung, ich hab's vergessen."),
        VSentence(vi: "Mình đi chợ mua rau nhé.", de: "Lass uns auf den Markt gehen und Gemüse kaufen."),
        VSentence(vi: "Bố ơi, mấy giờ rồi ạ?", de: "Papa, wie spät ist es?"),
        VSentence(vi: "Con muốn nói chuyện với bà.", de: "Ich möchte mit Oma sprechen."),
        VSentence(vi: "Không sao đâu, từ từ thôi.", de: "Halb so wild, immer langsam."),
        VSentence(vi: "Chữ Việt dùng bảng chữ cái La-tinh.", de: "Die vietnamesische Schrift benutzt das lateinische Alphabet."),
        VSentence(vi: "Con đọc được rồi, mẹ ơi!", de: "Ich kann's lesen, Mama!")
    ]

    static let consonants: [SoundCard] = [
        SoundCard(head: "đ", desc: "wie das deutsche „d“ in „du“.", warn: "Das Querstrichlein ist kein Schmuck — ohne ihn ist es ein ganz anderer Laut.", examples: [("đi","gehen"),("đói","hungrig"),("đẹp","schön")]),
        SoundCard(head: "d", desc: "Norden: stimmhaftes „s“ wie in „Rose“. Süden: „j“ wie in „ja“.", warn: "Nie wie ein deutsches d.", examples: [("dì","Tante"),("dễ","leicht"),("dạ","ja")]),
        SoundCard(head: "gi", desc: "Klingt genau wie d: „s“ (Norden) bzw. „j“ (Süden). Das i verschwindet dabei.", warn: "", examples: [("giờ","Uhrzeit"),("già","alt"),("giúp","helfen")]),
        SoundCard(head: "r", desc: "Norden: wie d, also „s“ in „Rose“. Süden: gerolltes r.", warn: "Nie das deutsche Rachen-r.", examples: [("rau","Gemüse"),("rồi","schon"),("rất","sehr")]),
        SoundCard(head: "tr", desc: "Norden: klingt wie ch. Süden: zurückgezogenes „tr“.", warn: "", examples: [("trà","Tee"),("trứng","Ei"),("trăm","hundert")]),
        SoundCard(head: "ch", desc: "Weiches „tj“, ähnlich dem ch in „Cello“ auf Italienisch.", warn: "", examples: [("chào","hallo"),("chị","ältere Schwester"),("chợ","Markt")]),
        SoundCard(head: "x", desc: "Scharfes „s“ wie in „Fuß“.", warn: "", examples: [("xe","Fahrzeug"),("xa","weit"),("xin","bitten")]),
        SoundCard(head: "s", desc: "Norden: wie x. Süden: „sch“.", warn: "", examples: [("sách","Buch"),("sáu","sechs"),("sáng","Morgen")]),
        SoundCard(head: "nh", desc: "Wie „ñ“ im Spanischen, wie „gn“ in Champagner.", warn: "", examples: [("nhà","Haus"),("nhỏ","klein"),("nhanh","schnell")]),
        SoundCard(head: "ng · ngh", desc: "„ng“ wie in „singen“ — nur eben am Wortanfang. ngh steht vor i, e, ê.", warn: "Das Schwerste für deutsche Ohren am Wortanfang.", examples: [("ngon","lecker"),("nghe","hören"),("nghìn","tausend")]),
        SoundCard(head: "kh", desc: "Wie das „ch“ in „Bach“.", warn: "", examples: [("không","nein"),("khỏe","gesund"),("khó","schwer")]),
        SoundCard(head: "ph", desc: "Immer „f“ — nie „p-h“.", warn: "", examples: [("phở","Phở"),("phòng","Zimmer")]),
        SoundCard(head: "th", desc: "Behauchtes t, wie im Englischen „top“.", warn: "", examples: [("thịt","Fleisch"),("thương","lieb haben"),("thích","mögen")]),
        SoundCard(head: "c · k · qu", desc: "Alle drei sind derselbe k-Laut. k steht vor i, e, ê, y. qu wird „kw“ gesprochen.", warn: "", examples: [("cá","Fisch"),("kem","Eis"),("quả","Frucht")]),
        SoundCard(head: "g · gh", desc: "Weiches, geriebenes g. gh steht vor i, e, ê.", warn: "", examples: [("gà","Huhn"),("ghế","Stuhl"),("gần","nah")]),
        SoundCard(head: "Endung -c -ch -p -t", desc: "Der Laut wird abgeschnitten, nicht ausgesprochen — die Luft stoppt einfach.", warn: "", examples: [("học","lernen"),("sách","Buch"),("biết","wissen")])
    ]

    static let vowels: [SoundCard] = [
        SoundCard(head: "a", desc: "Offenes, langes a wie in „Vater“.", warn: "", examples: [("ba","drei"),("cá","Fisch")]),
        SoundCard(head: "ă", desc: "Dasselbe a, aber ganz kurz. Steht nie allein.", warn: "", examples: [("ăn","essen"),("năm","fünf"),("mắm","Fischsauce")]),
        SoundCard(head: "â", desc: "Kurzes, dumpfes „ö“ ohne Lippenrundung — wie das e in „bitte“.", warn: "", examples: [("cần","brauchen"),("ấy","jene(r)"),("bận","beschäftigt")]),
        SoundCard(head: "e", desc: "Offenes ä wie in „Bär“.", warn: "", examples: [("em","jüngeres Geschwister"),("xe","Fahrzeug")]),
        SoundCard(head: "ê", desc: "Geschlossenes e wie in „See“.", warn: "", examples: [("đêm","Nacht"),("ghế","Stuhl"),("về","heimgehen")]),
        SoundCard(head: "o", desc: "Offenes o wie in „Sonne“.", warn: "", examples: [("con","Kind"),("ngon","lecker")]),
        SoundCard(head: "ô", desc: "Geschlossenes o wie in „Ofen“.", warn: "", examples: [("cô","Tante"),("tôi","ich"),("bốn","vier")]),
        SoundCard(head: "ơ", desc: "Wie â, aber lang gezogen.", warn: "Verwechsle das Hörnchen nicht mit einem Tonzeichen.", examples: [("mơ","träumen"),("giờ","Uhrzeit"),("ơi","he, du (Anrede)")]),
        SoundCard(head: "i · y", desc: "Beide klingen wie „i“ in „Liebe“.", warn: "", examples: [("đi","gehen"),("mì","Nudeln"),("bảy","sieben")]),
        SoundCard(head: "u", desc: "Wie „u“ in „Kuh“.", warn: "", examples: [("mua","kaufen"),("vui","fröhlich")]),
        SoundCard(head: "ư", desc: "Ein u mit völlig ungerundeten Lippen — kein deutscher Laut.", warn: "Auch hier ist das Hörnchen ein Vokalzeichen, kein Ton.", examples: [("thư","Brief"),("từ","Wort"),("nước","Wasser")])
    ]

    static let telexRows: [(String, String, String)] = [
        ("aa", "â", "caan → cân"),
        ("aw", "ă", "awn → ăn"),
        ("ee", "ê", "ddeem → đêm"),
        ("oo", "ô", "boon → bôn"),
        ("ow", "ơ", "giowf → giờ"),
        ("w · uw", "ư", "tuwf → từ"),
        ("uow", "ươ", "nuowcs → nước"),
        ("dd", "đ", "ddi → đi"),
        ("s", "á sắc", "cas → cá"),
        ("f", "à huyền", "baf → bà"),
        ("r", "ả hỏi", "hoir → hỏi"),
        ("x", "ã ngã", "ngax → ngã"),
        ("j", "ạ nặng", "mej → mẹ")
    ]

    static let alphabet: [String] = [
        "a","ă","â","b","c","d","đ","e","ê","g","h","i","k","l","m",
        "n","o","ô","ơ","p","q","r","s","t","u","ư","v","x","y"
    ]
    static let newLetters: Set<String> = ["ă","â","đ","ê","ô","ơ","ư"]
}
