package com.classes;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author dell
 */
public class User {
  private String username;
  private  String password;
  private  String email;
  private  String phone_number;
  private  String role;
  
  public User(String username,String password, String email,String phone_number){
      this.username = username;
      this.email = email;
      this.password = password;
      this.phone_number = phone_number;
      
  }
  public String get_username(){
      return username;
  }
  public String get_password(){
      return password;
  }
  public String get_email(){
      return email;
  }
  public String get_phone_number(){
      return phone_number;
  }
  public String get_role(){
         return role;
     }
  public void set_role(String role){
    this.role = role;
  }

      
}
