package com.javatechie.controller;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.javatechie.dto.Customer;

@RestController
@RequestMapping("/customers")
public class DockerInitController {
	
	 @GetMapping
	    public List<Customer> getCustomers() {
	        return Stream.of(new Customer(101, "Basant", "basant@gmail.com", "Male"),
	                        new Customer(102, "Santosh", "santosh@gmail.com", "Male"),
	                        new Customer(103, "Shruti", "shruti@gmail.com", "Female"))
	                .collect(Collectors.toList());
	    }

}
