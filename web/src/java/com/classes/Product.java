/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.classes;

/**
 *
 * @author dell
 */
public class Product {
    
    private String model_number;
    private String size;
    private String color;
    private String product_name;
    private String category;
    private String quantity;
    private String price;
    
    
    public Product(String model_number,String size,String color,String product_name,String category ){
        this.model_number = model_number;
        this.size = size;
        this.color = color;
        this.product_name = product_name;
        this.category = category;
        this.quantity = quantity;
    }
    public String get_model_number(){
        return model_number;
    }
    public String get_size(){
        return size;
    }
    public String get_product_name(){
        return product_name;
    }
    public String get_category(){
        return category;
    }
    public String get_color(){
        return color;
    }
    public String get_price(){
        return price;    }
    public void set_price(String price){
        this.price = price;
    }
  
    
    
    
}
