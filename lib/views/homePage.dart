import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/address.dart';

class ViaCepService {
  final Dio _dio = Dio();

  Future<Address> fetchAddress(String cep) async {
    try {
      final response = await _dio.get('https://viacep.com.br/ws/$cep/json/');
      if (response.statusCode == 200) {
        return Address.fromJson(response.data);
      } else {
        throw Exception('Failed to load address');
      }
    } catch (e) {
      throw Exception('Failed to load address: $e');
    }
  }
}

class AddressSearchScreen extends StatefulWidget {
  const AddressSearchScreen({super.key});

  @override
  AddressSearchScreenState createState() => AddressSearchScreenState();
}

class AddressSearchScreenState extends State<AddressSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ViaCepService _viaCepService = ViaCepService();
  Address? _address;
  bool _isLoading = false;
  String? _error;

  void _searchCep() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final address = await _viaCepService.fetchAddress(_controller.text);
      setState(() {
        _address = address;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador Endereço VIA CEP', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              maxLength: 9,
              decoration: const InputDecoration(
                labelText: 'Insira o CEP a ser buscado',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CustomFormatter(),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchCep,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                : _error != null
                ? Text('Error: $_error')
                : _address != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CEP: ${_address!.cep}'),
                Text('Logradouro: ${_address!.logradouro}'),
                Text('Complemento: ${_address!.complemento}'),
                Text('Bairro: ${_address!.bairro}'),
                Text('Localidade: ${_address!.localidade}'),
                Text('UF: ${_address!.uf}'),
              ],
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class CustomFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var newText = newValue.text;

    if (newText.length > 5 && newText.length < 9) {
      var buffer = StringBuffer();
      for (int i = 0; i < newText.length; i++) {
        buffer.write(newText[i]);
        if (i == 5 && i != newText.length - 1) {
          buffer.write('-');
        }
      }
      return TextEditingValue(
          text: buffer.toString(),
          selection: TextSelection.collapsed(offset: buffer.toString().length),

      );
    }
    return newValue;
  }
}