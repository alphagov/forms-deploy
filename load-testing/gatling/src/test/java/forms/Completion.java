package forms;

import io.gatling.javaapi.core.ChainBuilder;
import io.gatling.javaapi.core.CheckBuilder;
import io.gatling.javaapi.core.Choice;
import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;
import io.gatling.javaapi.http.HttpProtocolBuilder;

import java.time.Duration;
import java.util.Map;

import static io.gatling.javaapi.core.CoreDsl.constantConcurrentUsers;
import static io.gatling.javaapi.core.CoreDsl.css;
import static io.gatling.javaapi.core.CoreDsl.doSwitch;
import static io.gatling.javaapi.core.CoreDsl.exec;
import static io.gatling.javaapi.core.CoreDsl.rampConcurrentUsers;
import static io.gatling.javaapi.core.CoreDsl.scenario;
import static io.gatling.javaapi.http.HttpDsl.http;

public class Completion extends Simulation {

    private int rampDuration = Integer.parseInt(System.getenv().getOrDefault("RAMP_DURATION", "60"));
    private int maxConcurrentUsers = Integer.parseInt(System.getenv().getOrDefault("MAX_CONCURRENT_USERS", "75"));
    private int maxConcurrentDuration = Integer.parseInt(System.getenv().getOrDefault("MAX_CONCURRENT_DURATION", "120"));
    private int formId = Integer.parseInt(System.getenv().getOrDefault("FORM_ID", "71"));
    private String baseUrl = System.getenv().getOrDefault("BASE_URL", "https://submit.dev.forms.service.gov.uk");

    private HttpProtocolBuilder httpProtocol = http.
            baseUrl(baseUrl)
            .inferHtmlResources()
            .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8")
            .acceptEncodingHeader("gzip, deflate, br")
            .acceptLanguageHeader("en-GB,en;q=0.5")
            .upgradeInsecureRequestsHeader("1")
            .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/118.0");

    private Map<CharSequence, String> headers_0 = Map.of(
            "Sec-Fetch-Dest", "document",
            "Sec-Fetch-Mode", "navigate",
            "Sec-Fetch-Site", "none",
            "Sec-Fetch-User", "?1"
    );

    private Map<CharSequence, String> headers_1 = Map.of(
            "Origin", "https://submit.dev.forms.service.gov.uk",
            "Sec-Fetch-Dest", "document",
            "Sec-Fetch-Mode", "navigate",
            "Sec-Fetch-Site", "same-origin",
            "Sec-Fetch-User", "?1"
    );

    private ScenarioBuilder scn = scenario("RecordedSimulation")
            .exec(getStartPage(String.format("/form/%s", formId)))
            .asLongAs(session -> session.getString("input_name") != "false", "question_number").on(
                    exec(debug())
                            .exec(answerQuestion())
                            .pause(3, 10)
            )
            .exec(submitAnswers());

    {
        setUp(scn.injectClosed(
                rampConcurrentUsers(0).to(maxConcurrentUsers).during(rampDuration),
                constantConcurrentUsers(maxConcurrentUsers).during(maxConcurrentDuration),
                rampConcurrentUsers(maxConcurrentUsers).to(0).during(rampDuration)
        ).protocols(httpProtocol));
    }

    private ChainBuilder answerQuestion() {
        return doSwitch("#{input_name}").on(
                Choice.withKey("question[date(3i)]", exec(enterDate())),
                Choice.withKey("question[address1]", exec(enterAddress())),
                Choice.withKey("question[selection]", exec(enterAnswerOf("Blue"))),
                Choice.withKey("question[number]", exec(enterAnswerOf("42"))),
                Choice.withKey("question[email]", exec(enterAnswerOf("test@test.test"))),
                Choice.withKey("question[full_name]", exec(enterAnswerOf("Gatling Tester"))),
                Choice.withKey("question[text]", exec(enterAnswerOf("Just some text"))),
                Choice.withKey("question[phone_number]", exec(enterAnswerOf("01234567890"))),
                Choice.withKey("question[national_insurance_number]", exec(enterAnswerOf("AA123456D")))
        );
    }

    private ChainBuilder enterAnswerOf(String answer) {
        return exec(http("question #{question_number}")
                .post("#{action_path}")
                .requestTimeout(Duration.ofMinutes(1))
                .headers(headers_1)
                .formParam("authenticity_token", "#{auth_token}")
                .formParam("#{input_name}", answer)
                .check(getAuthToken())
                .check(getActionPath())
                .check(getInputName()));
    }

    private ChainBuilder enterAddress() {
        return exec(http("question #{question_number}")
                .post("#{action_path}")
                .requestTimeout(Duration.ofMinutes(1))
                .headers(headers_1)
                .formParam("question[address1]", "first line")
                .formParam("question[address2]", "second line")
                .formParam("question[town_or_city]", "the town")
                .formParam("question[county]", "the county")
                .formParam("question[postcode]", "SW1A 2AA")
                .formParam("authenticity_token", "#{auth_token}")
                .check(getAuthToken())
                .check(getActionPath())
                .check(getInputName()));
    }

    private ChainBuilder enterDate() {
        return exec(http("question #{question_number}")
                .post("#{action_path}")
                .requestTimeout(Duration.ofMinutes(1))
                .headers(headers_1)
                .formParam("authenticity_token", "#{auth_token}")
                .formParam("question[date(3i)]", "1")
                .formParam("question[date(2i)]", "1")
                .formParam("question[date(1i)]", "2023")
                .check(getAuthToken())
                .check(getActionPath())
                .check(getInputName()));
    }

    private ChainBuilder getStartPage(String path) {
        return exec(http("Get start page")
                .get(path)
                .requestTimeout(Duration.ofMinutes(1))
                .headers(headers_0)
                .check(getAuthToken())
                .check(getActionPath())
                .check(getInputName()));
    }

    private CheckBuilder getAuthToken() {
        return css("#main-content > div > div > form > input[name=authenticity_token][type=hidden]", "value")
                .saveAs("auth_token");
    }

    private CheckBuilder getActionPath() {
        return css("#main-content > div > div > form", "action")
                .saveAs("action_path");
    }

    private CheckBuilder getInputName() {
        return css(".govuk-input, .govuk-radios__input, .govuk-textarea", "name").withDefault("false")
                .saveAs("input_name");
    }

    private ChainBuilder submitAnswers() {
        return exec(http("submit answers")
                .post("#{action_path}")
                .requestTimeout(Duration.ofMinutes(1))
                .headers(headers_1)
                .formParam("authenticity_token", "#{auth_token}")
                .formParam("notify_reference", "b2654330-37bc-4fa7-9e16-6341d9798d0b"));
    }

    private ChainBuilder debug() {
        return exec(session -> {
//            System.out.println(session);
            return session;
        });
    }
}

