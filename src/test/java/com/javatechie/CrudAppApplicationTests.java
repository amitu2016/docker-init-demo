package com.javatechie;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class CrudAppApplicationTests {

    @Test
    void contextLoads() {
        //sample test
        int i = 10;
        int j = 10;
        assertEquals(i, j);
    }

}
