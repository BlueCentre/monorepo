package hello;

import static org.hamcrest.Matchers.*;
import static org.junit.Assert.*;

import java.net.URL;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

@SpringBootTest
public class HelloControllerIT {

    @Test
    public void contextLoads() {
    }

}

// @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
// public class HelloControllerIT {

//   @LocalServerPort
//   private int port;

//   private URL base;

//   @Autowired
//   private TestRestTemplate template;

//   @Before
//   public void setUp() throws Exception {
//     this.base = new URL("http://localhost:" + port + "/");
//   }

//   @Test
//   public void getHello() throws Exception {
//     ResponseEntity<String> response = template.getForEntity(base.toString(), String.class);
//     assertThat(response.getBody(), equalTo("Greetings from Spring Boot!"));
//   }
// }

// @RunWith(SpringRunner.class)
// @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
// public class HelloControllerIT {

//     @Test
//     void exampleTest(@Autowired WebTestClient webClient) {
//         webClient
//             .get().uri("/")
//             .exchange()
//             .expectStatus().isOk()
//             .expectBody(String.class).isEqualTo("Greetings from Spring Boot!");
//     }

// }
