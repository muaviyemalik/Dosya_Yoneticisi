import 'dart:io';
import 'package:flutter/material.dart';
import '../services/file_opener_service.dart';

class KlasorTarayiciEkrani extends StatefulWidget 
{
  final Directory dizin;

  const KlasorTarayiciEkrani({super.key, required this.dizin});

  @override
  State<KlasorTarayiciEkrani> createState() => _KlasorTarayiciEkraniState();
}

class _KlasorTarayiciEkraniState extends State<KlasorTarayiciEkrani> 
{
  List<FileSystemEntity> _icerik = [];

  Future<int> _dosyaSayisiniHesapla(Directory dir) async 
  {
    try 
    {
      // Klasörün içeriğini listeleyip sayısını döndür
      return dir.listSync().length;
    } 
    catch (e) 
    {
      // Erişimin olmadığı klasörler için 0 döndür
      return 0;
    }
  }

  @override
  void initState() 
  {
    super.initState();
    _diziniTara();
  }

  void _diziniTara() 
  {
    setState(() 
    {
      _icerik = widget.dizin.listSync();
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar(title: Text(widget.dizin.path.split('/').last)),
      body: ListView.builder
      (
        itemCount: _icerik.length,
        itemBuilder: (context, index) 
        {
          var entity = _icerik[index];
          bool isDir = entity is Directory;
          String isim = entity.path.split('/').last;

          return ListTile
          (
            leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file, color: isDir ? Colors.amber : Colors.blueGrey),
            title: Text(isim),
            trailing: isDir 
            ? FutureBuilder<int>
              (
                future: _dosyaSayisiniHesapla(entity as Directory),
                builder: (context, snapshot) 
                {
                  if (snapshot.connectionState == ConnectionState.waiting) 
                  {
                    return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  return Text('${snapshot.data ?? 0} öğe', style: const TextStyle(fontSize: 12, color: Colors.grey));
                },
              )
            : null,
            onTap: () 
            {
              if (isDir) 
              {
                Navigator.push
                (
                  context,
                  MaterialPageRoute(builder: (context) => KlasorTarayiciEkrani(dizin: entity as Directory)),
                );
              } 
              else 
              {
                FileOpenerService.dosyayiAc(context, entity.path, isim);
              }
            },
          );
        },
      ),
    );
  }
}