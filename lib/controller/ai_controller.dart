import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/io_client.dart';
import 'package:product_hunt/model/product.dart';

class AiController {
  static AiController? _instance;

  final _model = GenerativeModel(
    apiKey: dotenv.env['GEMINI_API_KEY']!,
    model: 'gemini-1.5-flash-latest',
    generationConfig:
        GenerationConfig(temperature: 0, responseMimeType: 'application/json'),
    httpClient: IOClient(),
  );

  AiController._();

  Future<Product> getInformationAboutProduct(File image) async {
    final Content content = Content.multi([
      DataPart('image/png', image.readAsBytesSync()),
      TextPart(
        'Given this image of a product to get information about in JSON format. includes title, description, fun_fact',
      ),
      // TextPart(
      //   'Search this product from the image and give top 10 products that fall into same category in JSON format. include title, link, ratings, pricing, imageLinks and dimensions of the product',
      // ),
      // TextPart(
      //   'Find this product online on famous shopping sites and retrieve multiple products in same category in JSON format. include title, links, ratings and dimensions of the product',
      // ),
      // TextPart('create comparable table to compare all the above products'),
      // TextPart('Write a story about a magic backpack.'),
    ]);

    print(content.toJson());

// To generate text output, call generateContent with the text input
    final response = await _model.generateContent(
      [content],
    );
    log(response.text ?? "nothing is generated", name: "generated");

    var text = response.text;
    if (text == null) {
      throw Exception("No text was generated");
    }

    return Product.fromJson(text);
  }

  static AiController getInstance() {
    var aiController = _instance ?? AiController._();
    _instance ??= aiController;
    return aiController;
  }
}
