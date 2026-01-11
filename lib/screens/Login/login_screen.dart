import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '..//../../consts.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return  Scaffold(
      body: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [g1, g2],
          ),
          ),
          child: Padding(
            padding:  EdgeInsets.all(size.height*0.030),
            child: SingleChildScrollView(
              child: OverflowBar(
                overflowAlignment: OverflowBarAlignment.center,
                overflowSpacing: size.height * 0.014,
                children: [
                  Image.asset(image1),
                  Text(
                    "Bem vindo de volta!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: kWhiteColor,
                    ),
                  ),
                     Text(
                    "Log In",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 34,
                      color: kWhiteColor,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.024),
                    TextField(
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        color: kInputColor),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 25.0),
                        filled: true,
                        hintText: "Email",
                        fillColor: kWhiteColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(37)
                        )
                      ),
                    ), 
                    TextField(
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        color: kInputColor),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 25.0),
                        filled: true,
                        hintText: "Senha",
                        fillColor: kWhiteColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(37)
                        )
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        alignment: Alignment.center,
                        height: size.height * 0.080,
                        decoration: BoxDecoration(
                          color: KButtonColor,
                          borderRadius: BorderRadius.circular(37),
                        ),
                        child: const Text (
                          "Entrar", 
                          style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                       onPressed: () {},
                    ),
                    SizedBox(height: size.height * 0.014),
                    Text(
                        "Não tem uma conta?",
                        style: TextStyle(
                          color: kWhiteColor,
                        ),
                      ),
                         CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Container(
                        alignment: Alignment.center,
                        height: size.height * 0.080,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 45,
                              spreadRadius: 0,
                              color: Color.fromRGBO(120, 37, 139, 0.25),
                              offset: Offset(0, 25)
                            )
                          ],
                          borderRadius: BorderRadius.circular(37),
                          color: Color.fromRGBO(225, 225, 225, 0.28),
                          
                        ),
                        child: const Text (
                          "Entrar", 
                          style: TextStyle(
                            color: kWhiteColor,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                       onPressed: () {},
                    )

                ],
              ),
            ),
          ),
      ),
    );
  }
}