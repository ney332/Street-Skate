import SwiftUI

struct SkateDrawView: View {
    var showDrawSkate: Bool

    // MARK: - State
    @State private var players: [String] = ["", ""]
    @State private var phase: Phase = .setup

    // Result
    @State private var orderedPlayers: [String] = []
    @State private var drawnTrick: String = ""

    // Roulette animation
    @State private var rouletteIndex: Int = 0
    @State private var rouletteColorIndex: Int = 0
    @State private var rouletteTimer: Timer? = nil
    @State private var rouletteInterval: Double = 0.07
    @State private var spinCount = 0
    @State private var totalSpins = 0

    // Result animation
    @State private var resultVisible = false
    @State private var trickVisible = false
    @State private var orderVisible = false
    @State private var winnerScale: CGFloat = 0.7

    enum Phase { case setup, spinning, result }

    // MARK: - Constants
    let maxPlayers = 8

    let rouletteColors: [Color] = [
        Color(red: 0.18, green: 0.95, blue: 0.44),
        Color(red: 0.27, green: 0.61, blue: 0.98),
        Color(red: 0.98, green: 0.36, blue: 0.36),
        Color(red: 0.98, green: 0.82, blue: 0.18),
        Color(red: 0.82, green: 0.36, blue: 0.98),
        Color(red: 0.18, green: 0.88, blue: 0.95),
        Color(red: 0.98, green: 0.55, blue: 0.20),
        Color(red: 0.95, green: 0.28, blue: 0.72),
    ]

    let tricks = [
        "Ollie", "Kickflip", "Heelflip", "Pop Shove-it", "360 Flip",
        "Hardflip", "Varial Kickflip", "Varial Heelflip", "Impossible",
        "Nollie", "Switch Ollie", "Fs 180", "Bs 180", "Fs 360", "Bs 360",
        "Fs Boardslide", "Bs Boardslide", "Noseslide", "Tailslide",
        "50-50 Grind", "5-0 Grind", "Nosegrind", "Crooked Grind",
        "Smith Grind", "Feeble Grind", "Blunt Slide", "Lip Slide",
        "Manual", "Nose Manual", "Casper Flip", "Hospital Flip",
        "Ghetto Bird", "Laser Flip", "Inward Heel", "Backside Flip",
        "Half Cab Kickflip", "Nollie Kickflip", "Switch Kickflip",
        "Fakie Ollie", "Fakie Kickflip", "Cab Flip", "Big Spin"
    ]

    // MARK: - Colors
    let bg = Color(red: 0.11, green: 0.11, blue: 0.12)
    let card = Color(red: 0.16, green: 0.16, blue: 0.18)
    let neon = Color(red: 0.18, green: 0.95, blue: 0.44)
    let textPrimary = Color.white
    let textSecondary = Color(white: 0.5)

    // MARK: - Computed
    var validPlayers: [String] {
        players.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
    var canDraw: Bool { validPlayers.count >= 2 }
    var currentRouletteColor: Color { rouletteColors[rouletteColorIndex % rouletteColors.count] }
    var currentRouletteName: String {
        guard !validPlayers.isEmpty else { return "" }
        return validPlayers[rouletteIndex % validPlayers.count]
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            // Fundo muda de cor durante o spin
            if phase == .spinning {
                currentRouletteColor
                    .opacity(0.12)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.06), value: rouletteColorIndex)
            }

            switch phase {
            case .setup:
                setupView
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            case .spinning:
                spinningView
                    .transition(.opacity.combined(with: .scale(scale: 1.03)))
            case .result:
                resultView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: phase)
    }

    // MARK: - Setup Screen
    var setupView: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 44)

                VStack(spacing: 6) {
                    Text("🛹")
                        .font(.system(size: 52))
                    Text("S.K.A.T.E")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(neon)
                        .shadow(color: neon.opacity(0.4), radius: 10)
                    Text("sorteio de jogadores")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(textSecondary)
                        .kerning(1)
                }

                VStack(spacing: 0) {
                    HStack {
                        Text("JOGADORES")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(textSecondary)
                            .kerning(2)
                        Spacer()
                        Text("\(validPlayers.count) / \(maxPlayers)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(textSecondary)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 10)

                    VStack(spacing: 8) {
                        ForEach(players.indices, id: \.self) { i in
                            playerRow(index: i)
                        }

                        if players.count < maxPlayers {
                            Button(action: addPlayer) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Adicionar jogador")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(
                                            style: StrokeStyle(lineWidth: 1, dash: [5])
                                        )
                                        .foregroundColor(textSecondary.opacity(0.3))
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Button(action: startDraw) {
                    HStack(spacing: 10) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 16, weight: .bold))
                        Text("Sortear")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(canDraw ? .black : textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(canDraw ? neon : card)
                    .cornerRadius(16)
                    .shadow(color: canDraw ? neon.opacity(0.35) : .clear, radius: 14, x: 0, y: 4)
                }
                .disabled(!canDraw)
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.2), value: canDraw)

                Spacer(minLength: 30)
            }
        }
    }

    func playerRow(index: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(card)
                    .frame(width: 30, height: 30)
                Text("\(index + 1)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(textSecondary)
            }

            TextField("Jogador \(index + 1)", text: $players[index])
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(textPrimary)
                .autocorrectionDisabled()
                .submitLabel(index < players.count - 1 ? .next : .done)

            if players.count > 2 {
                Button(action: { removePlayer(at: index) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(textSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.white.opacity(0.07))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(card)
        .cornerRadius(14)
    }

    // MARK: - Spinning Screen (Roleta)
    var spinningView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {

                Text("SORTEANDO...")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(currentRouletteColor.opacity(0.8))
                    .kerning(3)

                // Círculo central com nome piscando
                ZStack {
                    Circle()
                        .strokeBorder(currentRouletteColor.opacity(0.2), lineWidth: 2)
                        .frame(width: 270, height: 270)
                        .animation(.easeInOut(duration: 0.06), value: rouletteColorIndex)

                    Circle()
                        .fill(currentRouletteColor.opacity(0.06))
                        .frame(width: 250, height: 250)
                        .animation(.easeInOut(duration: 0.06), value: rouletteColorIndex)

                    VStack(spacing: 4) {
                        Text(currentRouletteName)
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(currentRouletteColor)
                            .shadow(color: currentRouletteColor.opacity(0.5), radius: 10)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.4)
                            .lineLimit(2)
                            .padding(.horizontal, 24)
                            .animation(.easeInOut(duration: max(0.04, rouletteInterval * 0.5)), value: rouletteIndex)
                    }
                }
                .frame(width: 270, height: 270)

                // Dots indicadores — um por jogador
                HStack(spacing: 8) {
                    ForEach(validPlayers.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == rouletteIndex % validPlayers.count
                                  ? currentRouletteColor
                                  : Color.white.opacity(0.15))
                            .frame(
                                width: i == rouletteIndex % validPlayers.count ? 22 : 8,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.15), value: rouletteIndex)
                    }
                }
            }

            Spacer()
        }
    }

    // MARK: - Result Screen
    var resultView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: 36)

                // Winner card
                VStack(spacing: 16) {
                    Text("COMEÇA")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(textSecondary)
                        .kerning(3)

                    Text(orderedPlayers.first ?? "")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(neon)
                        .shadow(color: neon.opacity(0.5), radius: 14)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                        .scaleEffect(winnerScale)
                        .animation(.spring(response: 0.55, dampingFraction: 0.6).delay(0.1), value: winnerScale)

                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.horizontal, 20)

                        Text("MANOBRA SORTEADA")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(textSecondary)
                            .kerning(2)

                        Text(drawnTrick)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(trickVisible ? 1 : 0)
                    .offset(y: trickVisible ? 0 : 10)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: trickVisible)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .padding(.horizontal, 24)
                .background(card)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(neon.opacity(0.35), lineWidth: 1.5)
                )
                .opacity(resultVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: resultVisible)
                .padding(.horizontal, 20)

                // Order list
                VStack(alignment: .leading, spacing: 10) {
                    Text("ORDEM DO JOGO")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(textSecondary)
                        .kerning(2)
                        .padding(.horizontal, 4)

                    VStack(spacing: 6) {
                        ForEach(orderedPlayers.indices, id: \.self) { i in
                            orderRow(position: i + 1, name: orderedPlayers[i])
                                .opacity(orderVisible ? 1 : 0)
                                .offset(x: orderVisible ? 0 : 24)
                                .animation(
                                    .spring(response: 0.45, dampingFraction: 0.75)
                                    .delay(0.5 + Double(i) * 0.08),
                                    value: orderVisible
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Buttons
                VStack(spacing: 10) {
                    Button(action: reshuffleDraw) {
                        HStack(spacing: 8) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Sortear novamente")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(neon)
                        .cornerRadius(16)
                        .shadow(color: neon.opacity(0.35), radius: 12, x: 0, y: 4)
                    }

                    Button(action: backToSetup) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 14))
                            Text("Editar jogadores")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(card)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .opacity(orderVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.9), value: orderVisible)

                Spacer(minLength: 30)
            }
        }
    }

    func orderRow(position: Int, name: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(position == 1 ? neon : Color.white.opacity(0.07))
                    .frame(width: 32, height: 32)
                Text("\(position)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(position == 1 ? .black : textSecondary)
            }

            Text(name)
                .font(.system(size: 16, weight: position == 1 ? .bold : .medium, design: .rounded))
                .foregroundColor(position == 1 ? textPrimary : textSecondary)

            Spacer()

            if position == 1 {
                Text("puxa primeiro")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(neon)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(neon.opacity(0.12))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(position == 1 ? neon.opacity(0.07) : card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(position == 1 ? neon.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - Logic

    func addPlayer() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            players.append("")
        }
    }

    func removePlayer(at index: Int) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            players.remove(at: index)
        }
    }

    func startDraw() {
        guard canDraw else { return }

        let shuffled = validPlayers.shuffled()
        orderedPlayers = shuffled
        drawnTrick = tricks.randomElement() ?? "Ollie"

        // O vencedor é shuffled[0]; calculamos onde ele está na lista validPlayers
        let winnerName = shuffled[0]
        let winnerLocalIndex = validPlayers.firstIndex(of: winnerName) ?? 0

        rouletteIndex = 0
        rouletteColorIndex = 0
        rouletteInterval = 0.07
        spinCount = 0

        // N voltas completas + parar no vencedor
        let fullLaps = Int.random(in: 3...5)
        totalSpins = fullLaps * validPlayers.count + winnerLocalIndex

        resultVisible = false
        trickVisible = false
        orderVisible = false
        winnerScale = 0.7

        phase = .spinning
        scheduleNextSpin()
    }

    func reshuffleDraw() {
        rouletteTimer?.invalidate()
        phase = .setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            startDraw()
        }
    }

    func scheduleNextSpin() {
        rouletteTimer?.invalidate()

        // Desacelera nos últimos 35% dos spins
        let progress = Double(spinCount) / Double(max(totalSpins, 1))
        if progress > 0.65 {
            let t = (progress - 0.65) / 0.35  // 0 → 1
            rouletteInterval = 0.07 + t * 0.33 // 0.07 → 0.40
        } else {
            rouletteInterval = 0.07
        }

        rouletteTimer = Timer.scheduledTimer(withTimeInterval: rouletteInterval, repeats: false) { _ in
            advanceSpin()
        }
    }

    func advanceSpin() {
        withAnimation(.easeInOut(duration: max(0.04, rouletteInterval * 0.55))) {
            rouletteIndex += 1
            rouletteColorIndex += 1
        }
        spinCount += 1

        if spinCount >= totalSpins {
            // Pausa dramática antes de revelar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showResult()
            }
        } else {
            scheduleNextSpin()
        }
    }

    func showResult() {
        phase = .result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            resultVisible = true
            winnerScale = 1.0
            trickVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            orderVisible = true
        }
    }

    func backToSetup() {
        rouletteTimer?.invalidate()
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .setup
        }
    }
}

#Preview {
    SkateDrawView(showDrawSkate: true)
}
