import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BloodAdvertisementPage extends StatefulWidget {
  const BloodAdvertisementPage({super.key});

  @override
  _BloodAdvertisementPageState createState() => _BloodAdvertisementPageState();
}

class _BloodAdvertisementPageState extends State<BloodAdvertisementPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<DocumentSnapshot>> getAllUserNeedDocs(String userId) async {
    try {
      // Firestore kullanıcının kimlik bilgilerini almak için FirebaseAuth kullanın
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Kullanıcı oturum açmamışsa, boş bir liste döndürün
        return [];
      }

      // kan-ihtiyacı koleksiyonunu referans alın
      CollectionReference donationCollectionRef =
          FirebaseFirestore.instance.collection('kan-ihtiyacı');

      // Koleksiyondaki belgeleri sorgulayın
      QuerySnapshot donationDocsQuerySnapshot = await donationCollectionRef
          .where('user-id', isEqualTo: userId) // userId alanına göre sorgula
          .get();

      // Belgeleri döndür
      return donationDocsQuerySnapshot.docs;
    } catch (e) {
      print('Belgeler alınırken bir hata oluştu: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEE2DE),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEEE2DE),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                size: 35), // Geri düğmesini büyütme
            onPressed: () {
              Navigator.pop(context); // Geri düğmesine basıldığında geri dön
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'İlan Verdiklerim'),
              Tab(text: 'Kan İhtiyacı Karşılanlar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder(
              future: getAllUserNeedDocs(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Veri bulunamadı'));
                } else {
                  // Tüm belgeler varsa
                  List<DocumentSnapshot<Object?>>? docs = snapshot.data;
                  return ListView.builder(
                    itemCount: docs?.length,
                    itemBuilder: (context, index) {
                      var docData = docs?[index].data() as Map<String, dynamic>;
                      return Container(
                        width: MediaQuery.of(context).size.width *
                            0.9, // Kart genişliğini ayarla
                        margin: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 24.0), // Kenar boşluğu ayarla
                        decoration: BoxDecoration(
                          color: Colors.white, // Kart rengini değiştir
                          borderRadius: BorderRadius.circular(
                              10.0), // Kartın kenarlarını yuvarla
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey
                                  .withOpacity(0.5), // Gölgelendirme rengi
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // Gölgelendirme boyutu ve yönü
                            ),
                          ],
                        ),
                        child: Card(
                          margin: const EdgeInsets.all(7),
                          color: const Color(0xFFFCDDB0),
                          elevation: 0, // Kartın gölge efektini kaldır
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Kartın kenarlarını yuvarla
                          ),
                          child: ListTile(
                            title: Text('Alıcı İsmi: ${docData['donor-name']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kan Grubu: ${docData['blood-type']}'),
                                Text(
                                    'Telefon Numarası: ${docData['phone-number']}'),
                                Text(
                                    'Yaşadığı Şehir: ${docData['living-city']}'),
                                Text(
                                    'Yayınlanma Tarihi: ${docData['confirm-date']}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
