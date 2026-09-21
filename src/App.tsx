import { BrowserRouter, Routes, Route } from "react-router-dom";
import { LocaleProvider } from "./LocaleContext";
import Layout from "./Layout";
import Home from "./pages/Home";
import Tickets from "./pages/Tickets";
import TicketQuiz from "./pages/TicketQuiz";
import Categories from "./pages/Categories";
import CategoryQuiz from "./pages/CategoryQuiz";
import Exam from "./pages/Exam";

function App() {
  return (
    <LocaleProvider>
      <BrowserRouter basename={import.meta.env.BASE_URL}>
        <Routes>
          <Route element={<Layout />}>
            <Route path="/" element={<Home />} />
            <Route path="/tickets" element={<Tickets />} />
            <Route path="/tickets/:number" element={<TicketQuiz />} />
            <Route path="/categories" element={<Categories />} />
            <Route path="/categories/:code" element={<CategoryQuiz />} />
            <Route path="/exam" element={<Exam />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </LocaleProvider>
  );
}

export default App;
